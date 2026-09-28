# 📄 CV

[![Build & Release](https://github.com/Enoal-Fauchille-Bolle/CV/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Enoal-Fauchille-Bolle/CV/actions/workflows/docker-publish.yml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Enoal-Fauchille-Bolle/CV)](https://github.com/Enoal-Fauchille-Bolle/CV/releases/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

> My résumé, containerized and served over Nginx. Automatically built, versioned, and published to GHCR on every release.

---

## 📖 About

This repository exists as a **DevOps learning exercise** as much as a CV hosting solution.

The goal was simple: instead of manually uploading a PDF somewhere and updating a link every time, I wanted to apply proper **release engineering** to something as humble as a résumé. That means:

- A **Docker image** embedding the PDF, served by a minimal Nginx on Alpine.
- A **GitHub Actions CI/CD pipeline** that automatically builds and publishes the image to GHCR on every annotated Git tag.
- A **versioned release** on every push, so any downstream system can track updates automatically.

This image is pulled by a **K3s homelab cluster** managed through GitOps (ArgoCD), which detects new image versions and updates the running container automatically.

---

## 🏗️ Stack

| Layer | Technology |
|---|---|
| Web server | [Nginx](https://nginx.org/) on [Alpine Linux](https://alpinelinux.org/) |
| Container registry | [GitHub Container Registry (GHCR)](https://ghcr.io) |
| CI/CD | [GitHub Actions](https://github.com/features/actions) |
| PDF editor | [Canva](https://www.canva.com/) |

---

## 🚀 Usage

### Pull and run the image locally

```bash
docker run -p 8080:80 ghcr.io/enoal-fauchille-bolle/cv:latest
```

Then open [http://localhost:8080](http://localhost:8080) — the PDF will be served directly.

### Build locally with Docker Compose

```bash
docker compose up --build
```

---

## 📦 Release workflow

New versions are published automatically via GitHub Actions when an **annotated Git tag** is pushed:

```bash
# 1. Commit your changes
git add resume.pdf
git commit -m "Update resume"

# 2. Create an annotated tag
git tag -a v2.4.0 -m "Add new experience"

# 3. Push everything
git push origin main
git push origin v2.4.0
```

The CI will then:
1. Build the Docker image.
2. Push it to GHCR with both the version tag and `latest`.
3. Create a GitHub Release with auto-generated release notes and the PDF attached.

---

## 📁 Project structure

```
.
├── .github/
│   └── workflows/
│       └── docker-publish.yml   # CI/CD pipeline
├── Dockerfile                   # Nginx Alpine image
├── docker-compose.yml           # Local development
├── nginx.conf                   # Nginx configuration
├── resume.pdf                   # The résumé itself
└── LICENSE
```

---

## 🔒 Private data

The repository is public, so `cv.yaml` only holds what may be published:
name, `contact@enoal.fr`, website, GitHub, LinkedIn and city. No driving licence.

The phone number lives in `private.yaml`, which is git-ignored and never leaves the machine:

```bash
cp private.example.yaml private.yaml   # then fill in the real values
typst compile --input private=true cv.typ cv-private.pdf
```

Without `--input private=true`, the template never reads `private.yaml`: that is the public build (CI, Release, enoal.fr).
With the flag but without the file, compilation fails instead of silently producing a PDF without the phone number.

---

## 🗂️ `cv.yaml` schema

The schema is documented in the header comment of [`cv.yaml`](./cv.yaml):
`{fr, en}` text, `"YYYY-MM"` dates, and an `id` plus `tags` on every entry for variant selection.

---

## 📝 License

[MIT © Enoal Fauchille-Bolle](./LICENSE)
