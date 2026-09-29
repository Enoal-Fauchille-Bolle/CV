# Build every CV variant from src/cv.typ through a pinned Typst container, so
# the output is byte-for-byte reproducible on any machine with Docker — no
# local Typst install needed. Typst is still 0.x, hence the exact version pin.
#
#   make            # public PDFs (FR + EN, no photo) into dist/
#   make private    # local build with photo + phone
#                   # (needs src/photo.jpg + src/private.yaml)
#   make check      # ATS checks on the public PDFs (needs poppler-utils)
#   make tags       # list the tags usable as TAG, and what each brings back
#   make TAG=rust   # one variant: `core` entries plus those tagged `rust`
#                   # (also `make private TAG=rust`, `make check TAG=rust`)
#   make image      # build the served nginx image locally (tag: cv)
#   make clean      # remove dist/
#
# The template imports no Typst packages, so the version below pins everything
# the build depends on. deploy/Dockerfile and the CI take it from here
# (`make typst-version`), so it is written in one place only.

TYPST_VERSION := 0.15.1
IMAGE   := ghcr.io/typst/typst:$(TYPST_VERSION)
RUN     := docker run --rm --user $(shell id -u):$(shell id -g) \
             -v "$(CURDIR)":/w -w /w $(IMAGE)
# --pdf-standard ua-1 emits a tagged, accessible PDF (better ATS parsing).
COMPILE := $(RUN) compile --font-path src/fonts --pdf-standard ua-1
SRC     := src/cv.typ
# TAG picks a per-offer variant (see `make tags`); empty means the default build.
# It becomes the `variant` input and a file-name suffix: ...-FR-rust.pdf.
TAG     :=
VARIANT := $(if $(TAG),$(TAG),full)
SUFFIX  := $(if $(TAG),-$(TAG))
DIST    := dist
# The file names are the ones recruiters see: the Release, the site and the
# Docker image all use them (deploy/nginx.conf, deploy/Dockerfile).
NAME    := CV-Enoal-Fauchille-Bolle

# A typo like TAG=rsut would silently build a CV with `core` entries only.
ifneq ($(TAG),)
ifeq ($(filter $(TAG),$(shell scripts/tags.sh --names)),)
$(error Unknown TAG '$(TAG)': run `make tags` to list the tags)
endif
endif

.PHONY: all public private check tags image typst-version clean

all: public

public: | $(DIST)
	$(COMPILE) --input lang=fr --input photo=false --input variant=$(VARIANT) $(SRC) $(DIST)/$(NAME)-FR$(SUFFIX).pdf
	$(COMPILE) --input lang=en --input photo=false --input variant=$(VARIANT) $(SRC) $(DIST)/$(NAME)-EN$(SUFFIX).pdf

# Requires src/photo.jpg and src/private.yaml (both git-ignored). Not part of
# `make all` so that a fresh clone always builds the public PDFs in one command.
private: | $(DIST)
	$(COMPILE) --input lang=fr --input photo=true --input private=true --input variant=$(VARIANT) $(SRC) $(DIST)/$(NAME)-FR$(SUFFIX)-private.pdf
	$(COMPILE) --input lang=en --input photo=true --input private=true --input variant=$(VARIANT) $(SRC) $(DIST)/$(NAME)-EN$(SUFFIX)-private.pdf

check: public
	scripts/check-ats.sh $(DIST)/$(NAME)-FR$(SUFFIX).pdf $(DIST)/$(NAME)-EN$(SUFFIX).pdf

tags:
	@scripts/tags.sh

# The build context is the repository root, so the Dockerfile can compile the
# PDFs itself; deploy/Dockerfile.dockerignore keeps private files out of it.
image:
	docker build --build-arg TYPST_VERSION=$(TYPST_VERSION) --build-arg NAME=$(NAME) \
	  -f deploy/Dockerfile -t cv .

typst-version:
	@echo $(TYPST_VERSION)

$(DIST):
	mkdir -p $(DIST)

clean:
	rm -rf $(DIST)
