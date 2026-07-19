# Validates every entry under people/*.yml against the schema documented
# in people/TEMPLATE.yml. Run with: julia --project=. scripts/validate_people.jl

using YAML
using Dates

const REPO_ROOT = normpath(joinpath(@__DIR__, ".."))
const PEOPLE_DIR = joinpath(REPO_ROOT, "people")
const PHOTOS_DIR = joinpath(PEOPLE_DIR, "photos")

const SLUG_RE = r"^[a-z0-9]+(-[a-z0-9]+)*\.yml$"
const URL_RE = r"^https?://"
const ORCID_RE = r"^https?://orcid\.org/\d{4}-\d{4}-\d{4}-\d{3}[\dXx]$"
const REQUIRED_FIELDS = ["name", "surname_sort", "affiliation", "research_areas", "links", "date_added"]
const MAX_BIO_LENGTH = 500
const MAX_RESEARCH_AREAS = 6
const MAX_PHOTO_BYTES = 1_000_000

function validate_file(path::String)
    errors = String[]
    fname = basename(path)

    if !occursin(SLUG_RE, fname)
        push!(errors, "filename \"$fname\" must be lowercase, hyphen-separated, e.g. jane-doe.yml")
    end

    local data
    try
        data = YAML.load_file(path)
    catch e
        push!(errors, "could not parse as YAML: $e")
        return errors
    end

    if !(data isa AbstractDict)
        push!(errors, "top-level YAML content must be a mapping of fields")
        return errors
    end

    for field in REQUIRED_FIELDS
        if !haskey(data, field) || data[field] === nothing || data[field] == "" || data[field] == []
            push!(errors, "missing required field \"$field\"")
        end
    end

    links = get(data, "links", nothing)
    if links !== nothing
        if !(links isa AbstractDict) || isempty(links)
            push!(errors, "\"links\" must be a non-empty mapping with at least one URL")
        else
            for (key, url) in links
                if !(url isa String) || !occursin(URL_RE, url)
                    push!(errors, "link \"$key\" must be an http(s) URL, got \"$url\"")
                end
            end
            if haskey(links, "orcid") && !occursin(ORCID_RE, links["orcid"])
                push!(errors, "\"orcid\" link doesn't look like a valid ORCID URL")
            end
        end
    end

    date_added = get(data, "date_added", nothing)
    if date_added !== nothing
        try
            Date(string(date_added), dateformat"y-m-d")
        catch
            push!(errors, "\"date_added\" must be in YYYY-MM-DD format, got \"$date_added\"")
        end
    end

    research_areas = get(data, "research_areas", nothing)
    if research_areas !== nothing
        if !(research_areas isa AbstractVector)
            push!(errors, "\"research_areas\" must be a list")
        elseif length(research_areas) > MAX_RESEARCH_AREAS
            push!(errors, "\"research_areas\" has $(length(research_areas)) entries, max is $MAX_RESEARCH_AREAS")
        end
    end

    bio = get(data, "bio", nothing)
    if bio !== nothing && length(string(bio)) > MAX_BIO_LENGTH
        push!(errors, "\"bio\" is $(length(string(bio))) characters, max is $MAX_BIO_LENGTH")
    end

    photo = get(data, "photo", nothing)
    if photo !== nothing
        photo_path = joinpath(REPO_ROOT, photo)
        if !isfile(photo_path)
            push!(errors, "\"photo\" points to \"$photo\" which does not exist")
        elseif filesize(photo_path) > MAX_PHOTO_BYTES
            push!(errors, "\"photo\" file is larger than $(MAX_PHOTO_BYTES ÷ 1_000_000)MB")
        end
    end

    return errors
end

function main()
    files = filter(f -> endswith(f, ".yml") && f != "TEMPLATE.yml", sort(readdir(PEOPLE_DIR)))

    if isempty(files)
        println("No entries to validate.")
        return
    end

    any_errors = false
    for f in files
        errors = validate_file(joinpath(PEOPLE_DIR, f))
        if !isempty(errors)
            any_errors = true
            println("✗ $f")
            for e in errors
                println("    - $e")
            end
        else
            println("✓ $f")
        end
    end

    if any_errors
        println("\nValidation failed.")
        exit(1)
    else
        println("\nAll entries valid.")
    end
end

main()
