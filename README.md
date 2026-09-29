# 📄 CV

[![Build & Release](https://github.com/Enoal-Fauchille-Bolle/CV/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Enoal-Fauchille-Bolle/CV/actions/workflows/docker-publish.yml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Enoal-Fauchille-Bolle/CV)](https://github.com/Enoal-Fauchille-Bolle/CV/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

> My résumé as code: written in YAML, typeset with Typst, containerized and
> served over Nginx, versioned and published to GHCR on every release.

---

## 📖 About

This repository exists as a **DevOps learning exercise** as much as a CV.

Instead of editing a PDF by hand and re-uploading it, the résumé gets the same
treatment as software:

- **Content as data** — every entry lives in [`src/cv.yaml`](./src/cv.yaml), in
  French and English, tagged for per-offer variants.
- **Reproducible build** — a [Typst](https://typst.app/) template renders it
  through a pinned container, so the PDF is identical on any machine.
- **Release engineering** — an annotated Git tag builds a Docker image, pushes
  it to GHCR and creates a GitHub Release.
- **GitOps deployment** — a **K3s homelab cluster** managed by ArgoCD pulls the
  image and updates the running container automatically.

---

## 🚀 Quick start

Only Docker and `make` are needed — no local Typst install.

```bash
make          # public PDFs (FR + EN, no photo) into dist/
make check    # public PDFs + ATS checks (needs poppler-utils)
make tags     # list the tags usable for a per-offer variant
make TAG=rust # one variant, e.g. for a Rust offer (see "Variants")
make private  # local build with photo + phone (see "Private data")
make image    # build the served nginx image locally
make clean    # remove dist/
```

A single `make` on a fresh clone produces `dist/CV-Enoal-Fauchille-Bolle-FR.pdf`
and `dist/CV-Enoal-Fauchille-Bolle-EN.pdf`: tagged PDF/UA-1 files with hyphenation off, so ATS keyword matching stays intact.
Generated PDFs live in `dist/` and are git-ignored.

---

## ⚙️ How it works

```
src/cv.yaml ──▶ src/cv.typ ──▶ typst compile (pinned container) ──▶ dist/*.pdf
  content        template        Makefile
```

The template takes optional Typst `--input` flags:

| Input | Values | Effect |
|---|---|---|
| `lang` | `fr` (default), `en` | language of the `{fr, en}` text |
| `photo` | `true` (default), `false` | show or hide the header photo |
| `private` | `false` (default), `true` | load `src/private.yaml` (phone) |
| `variant` | `full` (default), `<tag>` | keep `core` entries plus those tagged `<tag>` |
| `version` | empty (default), `v3.0.0`… | printed after the source link at the bottom of the page |

The Makefile sets `version` from `git describe --tags --always --dirty`, so a
PDF built on a release tag reads `v3.0.0`, and one built in between reads
`v3.0.0-2-gabc1234` (`-dirty` with uncommitted changes).

The `cv.yaml` schema is documented in its header comment: `{fr, en}` text,
`"YYYY-MM"` dates, and an `id` plus `tags` on every entry for variant selection.

### Variants

A variant is a CV tailored to one offer. Every entry in `cv.yaml` carries tags:

| Tag | Meaning |
|---|---|
| `core` | shown in every build |
| `extra` | hidden from the default build, brought back by a variant sharing another of its tags |
| anything else (`rust`, `devops`…) | a topic, usable as `TAG` |

```bash
make tags                # every tag, with the entries it brings back
make TAG=rust            # dist/CV-Enoal-Fauchille-Bolle-{FR,EN}-rust.pdf
make private TAG=rust    # same with photo + phone, ...-rust-private.pdf
```

A variant keeps the `core` entries plus those tagged `TAG`. It can also have its
own title and summary under `headline.variants.<tag>` in `cv.yaml`; whatever it
leaves out falls back to the default headline. An unknown `TAG`
stops the build instead of silently producing a bare CV. `make TAG=extra`
brings every entry back at once to review them; it is the only build allowed
to take two pages, and is never sent.

---

## 🔒 Private data

The repository is public, so `src/cv.yaml` only holds what may be published:
name, `contact@enoal.fr`, website, GitHub, LinkedIn and city. No driving licence.

Two things stay off the public repo and are git-ignored:

- **Phone** — lives in `src/private.yaml` (copy `src/private.example.yaml`).
- **Photo** — lives in `src/photo.jpg`.

```bash
cp src/private.example.yaml src/private.yaml   # then fill in the real number
# drop your photo.jpg into src/, then:
make private                                   # dist/cv-*-private.pdf
```

The public build (`make`) never sets `private=true` or `photo=true`, so it reads
neither file: no phone, no photo — safe for CI, the Release and enoal.fr. With
`private=true` but no file, compilation fails instead of silently shipping a PDF
without the number.

---

## 🔤 Fonts

Fonts are committed under `src/fonts/` so builds are identical on any machine,
and Typst loads them with `--font-path src/fonts` (wired into the `Makefile`):

| Use | Font | Licence |
|---|---|---|
| Name & section headings | [Dosis](https://fonts.google.com/specimen/Dosis) | SIL Open Font License 1.1 |
| Body text | [Hanken Grotesk](https://fonts.google.com/specimen/Hanken+Grotesk) | SIL Open Font License 1.1 |

Both are OFL, which explicitly allows redistribution — committing them is legal
and the build never falls back to a substitute font. The original Canva CV used
*Nourd* (Hanken Design Co.), licensed for personal use only and not
redistributable in a public repo; Hanken Grotesk is the free, OFL font by the
same designer, so the look stays close.

---

## 📦 Deployment

### Run the image

```bash
docker run -p 8080:80 ghcr.io/enoal-fauchille-bolle/cv:latest
```

Then open [http://localhost:8080](http://localhost:8080). The image compiles
the PDFs itself and serves them at:

| URL | Serves |
|---|---|
| `/` | French version (any unknown path too, so old links keep working) |
| `/en` | English version |
| `/CV-Enoal-Fauchille-Bolle-FR.pdf`, `/CV-Enoal-Fauchille-Bolle-EN.pdf` | Each version by file name |

To build and run it locally instead (the build context is the repository root,
so the image can compile the PDFs):

```bash
docker compose -f deploy/docker-compose.yml up --build
```

### Release

Pushing an **annotated Git tag** triggers the GitHub Actions pipeline:

```bash
git tag -a v2.4.0 -m "Add new experience"
git push origin main
git push origin v2.4.0
```

The CI then:
1. Builds the PDFs and runs the checks (`scripts/check-ats.sh`): ATS-readable
   text, one page, no phone number in public PDFs, no French in English ones.
   A failing check stops the release. The same checks run on every push and
   pull request, on the default build and on every `TAG` variant, public and
   private (with a stand-in phone number and photo, so the real ones never
   reach the CI).
2. Builds the Docker image, which compiles the PDFs with the same pinned Typst.
3. Pushes it to GHCR with both the version tag and `latest`.
4. Creates a GitHub Release with auto-generated notes and the checked PDFs
   (FR and EN, public versions) attached.

---

## 🏗️ Stack

| Layer | Technology |
|---|---|
| Typesetting | [Typst](https://typst.app/) (pinned container image) |
| Build | [GNU Make](https://www.gnu.org/software/make/) + [Docker](https://www.docker.com/) |
| Web server | [Nginx](https://nginx.org/) on [Alpine Linux](https://alpinelinux.org/) |
| Container registry | [GitHub Container Registry (GHCR)](https://ghcr.io) |
| CI/CD | [GitHub Actions](https://github.com/features/actions) |

---

## 📁 Project structure

```
.
├── .github/workflows/
│   ├── ci.yml                 # ATS checks on every push and pull request
│   └── docker-publish.yml     # CI/CD: image + Release on every tag
├── src/                       # everything the PDF is built from
│   ├── cv.typ                 # Typst template
│   ├── cv.yaml                # CV content (FR + EN), schema in its header
│   ├── private.example.yaml   # template for the git-ignored private.yaml
│   └── fonts/                 # Dosis + Hanken Grotesk (OFL)
├── deploy/                    # everything the served image is built from
│   ├── Dockerfile             # Typst stage compiles the PDFs, Nginx Alpine serves them
│   ├── Dockerfile.dockerignore # allowlist: keeps private files out of the image
│   ├── nginx.conf             # /, /en and the PDFs by name
│   └── docker-compose.yml     # local run
├── scripts/
│   ├── check-ats.sh           # ATS checks on the generated PDFs
│   └── tags.sh                # tags used in cv.yaml (make tags)
├── Makefile                   # reproducible PDF build into dist/
├── CONTRIBUTING.md            # editing rules (one page, commits…)
└── LICENSE
```

---

## 📝 License

[MIT © Enoal Fauchille-Bolle](./LICENSE)
