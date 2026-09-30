# Contributing

This is a personal CV, so the "contributors" are mostly me and the tools I work
with. These rules keep every edit consistent with decisions already made.

## Layout

- **One page, always.** Every combination must compile to a single page:
  `lang` ∈ {`fr`, `en`} × `photo` ∈ {`true`, `false`} × `private` ∈ {`false`,
  `true`}, and every `TAG` variant except `extra`, which shows every entry
  for review and is never sent. The CI enforces it on every variant, public
  and private; locally, run `make check`, or `scripts/check-ats.sh dist/*.pdf`
  after `make private`.
- **Do not touch the margins or the fonts** to make content fit. Shorten the
  text, or move things within the header, instead.
- **One line per bullet.** A bullet that wraps costs a line and is the first
  thing to rewrite.
- **Single column.** Two-column layouts are misread by ATS parsers.
- The name is written **Fauchille-Bolle**, with a single hyphen.

## Content

- All content lives in `src/cv.yaml`; the template (`src/cv.typ`) holds no CV
  text apart from section labels.
- Every new entry needs a unique `id` and its `tags`: `core` (always shown) or
  `extra` (hidden by default), then one to three topic tags. Reuse the ones
  `make tags` lists before inventing another. An entry with neither is shown
  by default and hidden by the variants that do not name its tags.
- Unfinished text is written `TODO(#<issue>)`: the template renders it in red
  italics, so a placeholder never ships unnoticed.
- The phone number and the photo stay out of the repository (see README,
  "Private data").

## Commits

- [Conventional Commits](https://www.conventionalcommits.org/): `feat:`,
  `fix:`, `refactor:`, `docs:`, `chore:`, `build:`, with an optional scope such
  as `fix(template):` or `fix(ci):`.
- Add `Closes #<issue>` when a commit finishes a roadmap issue.
