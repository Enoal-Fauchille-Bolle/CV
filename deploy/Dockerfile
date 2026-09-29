# Build from the repository root so the first stage can see src/:
#   docker build -f deploy/Dockerfile .      (or: make image)
# Stage 1 compiles the public PDFs (same flags as the Makefile), stage 2 only
# serves them. Neither the Typst image nor the sources end up in the final image.

# Default for a bare `docker build`; the Makefile and the CI pass the version
# from the Makefile, the single place where it is pinned.
ARG TYPST_VERSION=0.15.1

FROM ghcr.io/typst/typst:${TYPST_VERSION} AS build
ARG NAME=CV-Enoal-Fauchille-Bolle
WORKDIR /w
COPY src/cv.typ src/cv.yaml ./src/
COPY src/fonts ./src/fonts
RUN mkdir dist \
 && for lang in fr en; do \
      typst compile --font-path src/fonts --pdf-standard ua-1 \
        --input lang=$lang --input photo=false \
        src/cv.typ "dist/${NAME}-$(echo $lang | tr a-z A-Z).pdf"; \
    done

FROM nginx:alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /w/dist/ /usr/share/nginx/html/
