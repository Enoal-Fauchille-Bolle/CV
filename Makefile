# Build every CV variant from cv.typ through a pinned Typst container, so the
# output is byte-for-byte reproducible on any machine with Docker — no local
# Typst install needed. Typst is still 0.x, hence the exact version pin.
#
#   make            # public PDFs (FR + EN, no photo) into dist/
#   make private    # local build with photo + phone (needs photo.jpg + private.yaml)
#   make clean      # remove dist/
#
# The template imports no Typst packages, so the image tag below pins every
# version the build depends on.

IMAGE   := ghcr.io/typst/typst:0.15.1
RUN     := docker run --rm --user $(shell id -u):$(shell id -g) \
             -v "$(CURDIR)":/w -w /w $(IMAGE)
# --pdf-standard ua-1 emits a tagged, accessible PDF (better ATS parsing).
COMPILE := $(RUN) compile --font-path fonts --pdf-standard ua-1
DIST    := dist

.PHONY: all public private clean

all: public

public: | $(DIST)
	$(COMPILE) --input lang=fr --input photo=false cv.typ $(DIST)/cv-fr.pdf
	$(COMPILE) --input lang=en --input photo=false cv.typ $(DIST)/cv-en.pdf

# Requires photo.jpg and private.yaml (both git-ignored). Not part of `make all`
# so that a fresh clone always builds the public PDFs with one command.
private: | $(DIST)
	$(COMPILE) --input lang=fr --input photo=true --input private=true cv.typ $(DIST)/cv-fr-private.pdf
	$(COMPILE) --input lang=en --input photo=true --input private=true cv.typ $(DIST)/cv-en-private.pdf

$(DIST):
	mkdir -p $(DIST)

clean:
	rm -rf $(DIST)
