# Converts an "Add my entry" issue (see .github/ISSUE_TEMPLATE/add-entry.yml)
# into a people/*.yml entry, so contributors never need to fork the repo.
#
# Reads the issue body from the ISSUE_BODY environment variable and writes
# people/<slug>.yml. Prints the slug on stdout so the workflow can pick it up.
#
# Run with: ISSUE_BODY="$(cat issue.md)" julia --project=. scripts/entry_from_issue.jl

using Dates
using Unicode

const REPO_ROOT = normpath(joinpath(@__DIR__, ".."))
const PEOPLE_DIR = joinpath(REPO_ROOT, "people")

const VALID_LINK_KEYS = ["website", "lab_website", "google_scholar", "orcid", "linkedin"]
const MAX_RESEARCH_AREAS = 6

struct EntryError <: Exception
    msg::String
end

function parse_issue_body(body::AbstractString)
    sections = Dict{String,String}()
    current = ""
    buffer = String[]

    flush!() = if !isempty(current)
        value = strip(join(buffer, "\n"))
        sections[current] = value == "_No response_" ? "" : value
    end

    for line in split(replace(body, "\r\n" => "\n"), "\n")
        m = match(r"^###\s+(.*?)\s*$", line)
        if m !== nothing
            flush!()
            current = m.captures[1]
            empty!(buffer)
        elseif !isempty(current)
            push!(buffer, line)
        end
    end
    flush!()

    return sections
end

function lines_of(value::AbstractString)
    return filter(!isempty, strip.(split(value, "\n")))
end

function slugify(name::AbstractString)
    ascii = Unicode.normalize(name, stripmark = true)
    lowered = lowercase(ascii)
    hyphenated = replace(lowered, r"[^a-z0-9]+" => "-")
    slug = strip(hyphenated, '-')
    isempty(slug) && throw(EntryError(
        "couldn't derive a filename from your name automatically — this happens " *
        "when it's written in a script the filename rules can't represent. " *
        "Nothing is wrong with your submission; a maintainer will add it for you shortly.",
    ))
    return slug
end

const PHOTO_HOST_RE = r"^https://(github\.com/user-attachments/assets/|user-images\.githubusercontent\.com/|private-user-images\.githubusercontent\.com/)"

function parse_photo_url(value::AbstractString)
    isempty(value) && return ""

    m = match(r"!\[[^\]]*\]\(([^)\s]+)", value)
    url = m !== nothing ? m.captures[1] : strip(value)

    occursin(r"^\s*$", url) && return ""
    if !occursin(PHOTO_HOST_RE, url)
        throw(EntryError("the photo needs to be attached by dragging the image into the form, rather than linked from elsewhere"))
    end
    return url
end

function yaml_string(value::AbstractString)
    escaped = replace(value, "\\" => "\\\\", "\"" => "\\\"")
    return "\"$escaped\""
end

function normalize_url(key::AbstractString, url::AbstractString)
    if key == "orcid" && occursin(r"^\d{4}-\d{4}-\d{4}-\d{3}[\dXx]$", url)
        return "https://orcid.org/" * url
    end
    if key == "linkedin" && occursin(r"^[\w\-]+$", url)
        return "https://www.linkedin.com/in/" * url
    end
    if key == "google_scholar" && occursin(r"^[\w\-]+$", url)
        return "https://scholar.google.com/citations?user=" * url
    end
    if !occursin(r"^https?://", url) && occursin(r"^[\w.-]+\.[A-Za-z]{2,}(/.*)?$", url)
        return "https://" * url
    end
    return url
end

function parse_links(value::AbstractString)
    isempty(value) && throw(EntryError("\"Links\" is required — give at least one, as `key: url`"))

    links = Pair{String,String}[]
    for line in lines_of(value)
        m = match(r"^[-*]?\s*([A-Za-z_]+)\s*[:=]\s*(\S+)$", line)
        if m === nothing
            throw(EntryError("couldn't read the link line `$line` — use `key: url`, e.g. `website: https://example.com`"))
        end
        key, url = lowercase(m.captures[1]), m.captures[2]
        if !(key in VALID_LINK_KEYS)
            throw(EntryError("`$key` isn't a recognised link type. Use one of: $(join(VALID_LINK_KEYS, ", "))"))
        end
        url = normalize_url(key, url)
        if !occursin(r"^https?://", url)
            throw(EntryError("couldn't read `$url` as a web address for `$key` — it should look like https://example.com"))
        end
        push!(links, key => url)
    end

    isempty(links) && throw(EntryError("\"Links\" needs at least one `key: url` line"))
    return links
end

function build_entry(sections::Dict{String,String})
    get_field(name) = get(sections, name, "")

    for required in ["Name", "Surname for sorting", "Affiliation", "Research areas"]
        isempty(get_field(required)) && throw(EntryError("\"$required\" is required but was left blank"))
    end

    name = get_field("Name")
    links = parse_links(get_field("Links"))

    research_areas = lines_of(get_field("Research areas"))
    isempty(research_areas) && throw(EntryError("\"Research areas\" needs at least one entry"))
    if length(research_areas) > MAX_RESEARCH_AREAS
        throw(EntryError("\"Research areas\" has $(length(research_areas)) entries, the maximum is $MAX_RESEARCH_AREAS"))
    end

    identities = filter(!isempty, strip.(split(get_field("Group(s) you self-identify with (optional)"), ",")))
    bio = replace(get_field("Short bio (optional)"), "\n" => " ")
    location = get_field("Location (optional)")

    io = IOBuffer()
    println(io, "name: ", yaml_string(name))
    println(io, "surname_sort: ", yaml_string(get_field("Surname for sorting")))
    println(io, "affiliation: ", yaml_string(get_field("Affiliation")))
    isempty(location) || println(io, "location: ", yaml_string(location))

    println(io, "\nresearch_areas:")
    for area in research_areas
        println(io, "  - ", yaml_string(area))
    end

    println(io, "\nlinks:")
    for (key, url) in links
        println(io, "  ", key, ": ", yaml_string(url))
    end

    if !isempty(identities)
        println(io, "\nidentities:")
        for identity in identities
            println(io, "  - ", yaml_string(identity))
        end
    end

    isempty(bio) || println(io, "\nbio: ", yaml_string(bio))
    println(io, "\ndate_added: ", yaml_string(string(today())))

    photo_url = parse_photo_url(get_field("Photo (optional)"))
    return slugify(name), String(take!(io)), photo_url
end

function main()
    body = get(ENV, "ISSUE_BODY", "")
    isempty(strip(body)) && throw(EntryError("the issue body was empty"))

    slug, content, photo_url = build_entry(parse_issue_body(body))
    path = joinpath(PEOPLE_DIR, "$slug.yml")

    if isfile(path)
        throw(EntryError("`people/$slug.yml` already exists. If that's you and you're updating your entry, please edit the file directly or email the maintainers."))
    end

    write(path, content)
    println(slug)
    println(photo_url)
end

try
    main()
catch e
    if e isa EntryError
        println(stderr, e.msg)
        exit(1)
    end
    rethrow()
end
