# Build every CV variant from src/cv.typ through a pinned Typst container, so
# the output is byte-for-byte reproducible on any machine with Docker — no
# local Typst install needed. Typst is still 0.x, hence the exact version pin.
#
#   make            # public PDFs (FR + EN, no photo) into dist/
#   make private    # local build with photo + phone
#                   # (needs src/photo.jpg + src/private.yaml)
#   make clean      # remove dist/
#
# The template imports no Typst packages, so the image tag below pins every
# version the build depends on.

IMAGE   := ghcr.io/typst/typst:0.15.1
RUN     := docker run --rm --user $(shell id -u):$(shell id -g) \
             -v "$(CURDIR)":/w -w /w $(IMAGE)
# --pdf-standard ua-1 emits a tagged, accessible PDF (better ATS parsing).
COMPILE := $(RUN) compile --font-path src/fonts --pdf-standard ua-1
SRC     := src/cv.typ
DIST    := dist

.PHONY: all public private clean

all: public

public: | $(DIST)
	$(COMPILE) --input lang=fr --input photo=false $(SRC) $(DIST)/cv-fr.pdf
	$(COMPILE) --input lang=en --input photo=false $(SRC) $(DIST)/cv-en.pdf

# Requires src/photo.jpg and src/private.yaml (both git-ignored). Not part of
# `make all` so that a fresh clone always builds the public PDFs in one command.
private: | $(DIST)
	$(COMPILE) --input lang=fr --input photo=true --input private=true $(SRC) $(DIST)/cv-fr-private.pdf
	$(COMPILE) --input lang=en --input photo=true --input private=true $(SRC) $(DIST)/cv-en-private.pdf

$(DIST):
	mkdir -p $(DIST)

clean:
	rm -rf $(DIST)
