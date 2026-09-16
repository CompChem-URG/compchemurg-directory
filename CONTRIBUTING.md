# Contributing

## Please read this first

Entries are only ever added with the consent of the person listed. **Do not add another person** — even with good intentions. If you'd like to nominate someone else, point them here so they can add themselves. (If someone emails us their own details, a maintainer may add the entry for them.)

## Adding yourself

The easiest way is the [entry form](../../issues/new?template=add-entry.yml) — fill it in and a pull request is opened for you automatically, with no forking and nothing to install.

To write the entry yourself instead, it can still all be done in your browser.

1. Open [`people/TEMPLATE.yml`](people/TEMPLATE.yml) and copy its contents.
2. Click [**create a new file in `people/`**](../../new/main/people). GitHub will make your own copy of the repository automatically the first time you do this.
3. Name the file `your-name.yml` (lowercase, hyphen-separated — e.g. `jane-doe.yml`). If that name is already taken, disambiguate with a middle initial (`jane-a-doe.yml`).
4. Paste the template in and fill it out. `name`, `surname_sort`, `affiliation`, `research_areas`, at least one entry under `links`, and `date_added` are required; everything else — `location`, `photo`, `identities`, `bio` — is optional and can be left out entirely.
5. Click **Propose new file**, then **Create pull request**. A GitHub Action automatically checks your file against the schema; a maintainer then reviews and merges it.

To include a photo, add it under `people/photos/` (under 1MB) and reference it from your entry's `photo` field. Uploading images is easier after step 5 — add it to the same pull request, or just mention in the pull request that you'd like one and a maintainer will help.

If you'd rather work locally: fork the repository, clone your fork, add your file on a branch, push, and open a pull request. (A plain clone of this repository isn't enough — you need a fork to have somewhere to push to.)

No GitHub account? Email [compchemurg@gmail.com](mailto:compchemurg@gmail.com) with your details and a maintainer will add the entry for you — see the [Contribute page](https://compchem-urg.github.io/compchemurg-directory/contribute/) for what to include.

## Updating your entry

Open a pull request editing your existing `people/your-name.yml` file the same way, or email [compchemurg@gmail.com](mailto:compchemurg@gmail.com) with the changes.

## Requesting a removal

Use the [removal request issue template](../../issues/new?template=removal-request.yml), or email [compchemurg@gmail.com](mailto:compchemurg@gmail.com), rather than a pull request — removal is handled directly by a maintainer, since it can call for judgment or sensitivity (for example, if someone has passed away and can't request the change themselves). Anyone can request a removal, not only the person listed.

## What review checks for

The automated check only validates the YAML file's structure (required fields, valid links, filename format, and so on). A maintainer separately checks that the pull request plausibly comes from the person themselves and isn't spam or abuse before merging.

## About the data you submit

Opening a pull request with your own `people/*.yml` file, submitting the entry form, or emailing us your details, is your confirmation that you consent to that information being published in this directory. This is separate from the [MIT license](LICENSE) covering this repository's code: the maintainers don't claim rights to reuse your personal data beyond displaying it here, and you can ask for it to be removed at any time via a removal request. See the site's [Privacy](https://compchem-urg.github.io/compchemurg-directory/privacy/) page for the full picture.
