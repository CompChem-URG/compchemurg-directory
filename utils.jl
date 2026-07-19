using YAML

const PEOPLE_DIR = joinpath(@__DIR__, "people")

const LINK_LABELS = Dict(
    "website" => "Website",
    "lab_website" => "Lab website",
    "google_scholar" => "Google Scholar",
    "orcid" => "ORCID",
    "linkedin" => "LinkedIn",
)

escape_html(s) = replace(
    string(s),
    "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", "\"" => "&quot;", "'" => "&#39;",
)

function _load_people()
    entries = []
    for f in sort(readdir(PEOPLE_DIR))
        (endswith(f, ".yml") && f != "TEMPLATE.yml") || continue
        push!(entries, YAML.load_file(joinpath(PEOPLE_DIR, f)))
    end
    sort!(entries; by = e -> lowercase(get(e, "surname_sort", "")))
    return entries
end

function _render_tags(areas)
    isempty(areas) && return ""
    tags = join(("<span class=\"tag\">$(escape_html(a))</span>" for a in areas), "\n      ")
    return """<div class="person-tags">
      $tags
    </div>"""
end

function _render_links(links)
    isempty(links) && return ""
    items = join(
        ("<a href=\"$(escape_html(url))\" target=\"_blank\" rel=\"noopener\">$(escape_html(get(LINK_LABELS, key, key)))</a>"
         for (key, url) in links),
        "\n      ",
    )
    return """<div class="person-links">
      $items
    </div>"""
end

function _render_card(e)
    name = escape_html(get(e, "name", ""))
    affiliation = escape_html(get(e, "affiliation", ""))
    location = get(e, "location", "")
    areas = get(e, "research_areas", String[])
    links = get(e, "links", Dict())
    bio = get(e, "bio", "")
    identities = get(e, "identities", String[])

    data_areas = escape_html(join(areas, "|"))
    data_location = escape_html(location)

    location_html = isempty(location) ? "" : "<div class=\"person-location\">$(escape_html(location))</div>"
    bio_html = isempty(bio) ? "" : "<p class=\"person-bio\">$(escape_html(bio))</p>"
    identities_html = isempty(identities) ?
        "" :
        "<div class=\"person-identities\">$(join((escape_html(i) for i in identities), ", "))</div>"

    return """<div class="person-card" data-research-areas="$data_areas" data-location="$data_location">
  <div class="person-name">$name</div>
  <div class="person-affiliation">$affiliation</div>
  $location_html
  $(_render_tags(areas))
  $(_render_links(links))
  $bio_html
  $identities_html
</div>"""
end

hfun_people_listing() = join(_render_card.(_load_people()), "\n")

function hfun_location_options()
    locations = Set{String}()
    for e in _load_people()
        loc = get(e, "location", "")
        isempty(loc) || push!(locations, loc)
    end
    options = join(
        ("<option value=\"$(escape_html(l))\">$(escape_html(l))</option>" for l in sort(collect(locations))),
        "\n    ",
    )
    return options
end
