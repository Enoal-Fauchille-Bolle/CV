# Build from the repository root so the first stage can see src/:
#   docker build -f deploy/Dockerfile .      (or: make image)
# Stage 1 compiles the public PDFs (same flags as the Makefile), stage 2 only
# serves them. Neither the Typst image nor the sources end up in the final image.

# The Typst version, written here only: the Makefile and the CI read this line
# (`make typst-version`), and a bare `docker build` or Compose uses it as is.
ARG TYPST_VERSION=0.15.1

FROM ghcr.io/typst/typst:${TYPST_VERSION} AS build
ARG NAME=CV-Enoal-Fauchille-Bolle
# No .git in the build context: the Makefile and the CI pass `git describe`.
ARG VERSION=
# The PDF creation date (Typst reads this variable): the last commit's, from
# the Makefile and the CI, so the image holds the same bytes as the Release.
ARG SOURCE_DATE_EPOCH=0
WORKDIR /w
COPY src/cv.typ src/cv.yaml ./src/
COPY src/fonts ./src/fonts
RUN mkdir dist \
 && for lang in fr en; do \
      typst compile --font-path src/fonts --pdf-standard ua-1 \
        --input lang=$lang --input photo=false --input version=$VERSION \
        src/cv.typ "dist/${NAME}-$(echo $lang | tr a-z A-Z).pdf"; \
    done

FROM nginx:1.31-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /w/dist/ /usr/share/nginx/html/
