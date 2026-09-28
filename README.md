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
make private  # local build with photo + phone (see "Private data")
make clean    # remove dist/
```

A single `make` on a fresh clone produces `dist/cv-fr.pdf` and `dist/cv-en.pdf`:
tagged PDF/UA-1 files with hyphenation off, so ATS keyword matching stays intact.
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

The `cv.yaml` schema is documented in its header comment: `{fr, en}` text,
`"YYYY-MM"` dates, and an `id` plus `tags` on every entry for variant selection.

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

> **Transitional:** the image and the Release still ship the hand-made
> `deploy/resume.pdf`. Switching them to the Typst-built PDF is tracked in
> issues #16–#20.

### Run the image

```bash
docker run -p 8080:80 ghcr.io/enoal-fauchille-bolle/cv:latest
```

Then open [http://localhost:8080](http://localhost:8080) — the PDF is served
directly. To build and run it locally instead:

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
1. Builds the Docker image from `deploy/`.
2. Pushes it to GHCR with both the version tag and `latest`.
3. Creates a GitHub Release with auto-generated notes and the PDF attached.

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
│   └── docker-publish.yml     # CI/CD: image + Release on every tag
├── src/                       # everything the PDF is built from
│   ├── cv.typ                 # Typst template
│   ├── cv.yaml                # CV content (FR + EN), schema in its header
│   ├── private.example.yaml   # template for the git-ignored private.yaml
│   └── fonts/                 # Dosis + Hanken Grotesk (OFL)
├── deploy/                    # everything the served image is built from
│   ├── Dockerfile             # Nginx Alpine image
│   ├── nginx.conf             # serves the PDF at /
│   ├── docker-compose.yml     # local run
│   └── resume.pdf             # hand-made PDF, until issues #16–#20
├── Makefile                   # reproducible PDF build into dist/
├── CONTRIBUTING.md            # editing rules (one page, commits…)
└── LICENSE
```

---

## 📝 License

[MIT © Enoal Fauchille-Bolle](./LICENSE)
