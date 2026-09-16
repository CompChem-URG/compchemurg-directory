# CompChemURG Directory

A community-maintained directory of people from underrepresented groups working in and around computational chemistry. Part of [CompChemURG](https://github.com/CompChem-URG/compchemurg).

## Inspiration

This project was inspired by USC's [Women in Theoretical/Computational Chemistry](https://iopenshell.usc.edu/wtc/) directory, which shaped its format (an alphabetical, searchable directory). It is an independent, unaffiliated project. Every entry here is contributed directly by the person it describes — see [Contributing](#contributing).

## Contributing

To add yourself to the directory, or to update your existing entry, see [CONTRIBUTING.md](CONTRIBUTING.md) — or, if you'd rather not use GitHub, fill in the form on the site's [Contribute](https://compchem-urg.github.io/compchemurg-directory/contribute/) page, or email [compchemurg@gmail.com](mailto:compchemurg@gmail.com).

To request that an entry be removed, [open a removal request](../../issues/new?template=removal-request.yml) or email [compchemurg@gmail.com](mailto:compchemurg@gmail.com).

## License

The site's code (templates, scripts, styling) is [MIT licensed](LICENSE).

Personal information in `people/*.yml` is not code — it's contributed by each individual about themselves. Opening a pull request with your entry is your confirmation that you consent to that information being published in this directory. This is not a grant of rights under the MIT license above; the maintainers don't claim ownership or broader reuse rights over your personal data beyond displaying it here, and it can be removed on request at any time.

## Development

### Setup

Install [Julia](https://julialang.org/downloads/) (version `1.12.6`, matching `.github/workflows/deploy.yml`), then instantiate the project's environment from the repo root:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### Serve locally

```bash
julia --project=. -e 'using Franklin; serve()'
```

Open http://localhost:8000 in your browser. Edits to pages, `_layout/`, and
`people/*.yml` live-reload automatically; SCSS changes need a manual recompile
(see [Styling](#styling)). `__site/` is gitignored and rebuilt by the deploy
workflow.

> Preview through `serve()`, not a plain static server on `__site/` — the
> production build prefixes asset paths for GitHub Pages, so CSS won't load at
> the server root.

### Validating entries locally

```bash
julia --project=. scripts/validate_people.jl
```

This is the same check that runs in CI on pull requests touching `people/**`.

### Styling

Any changes to the CSS should be made to the SCSS files in `_sass/` and compiled using `Sass.jl` as follows:

```julia
Sass.compile_file("style.scss", "../_css/celeste.min.css"; output_style = Sass.compressed)
```

This site shares its Franklin.jl/Celeste-based styling with [compchemurg](https://github.com/CompChem-URG/compchemurg) for visual consistency between the two sites.
