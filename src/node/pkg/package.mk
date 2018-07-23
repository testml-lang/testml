export PATH := $(ROOT)/src/testml-compiler-perl5/bin:$(PATH)

B := build
P := pkg

NAME ?= $(shell grep '^  "name":' $P/package.json | cut -d'"' -f4)
VERSION ?= $(shell grep '^  "version":' $P/package.json | cut -d'"' -f4)
DISTDIR := $(NAME)-$(VERSION)
DIST := $(DISTDIR).tgz
TAG_PREFIX := pkg-node

LIBS := \
    $(ALL_JS) \
    lib/testml/browser.js

ALL_LIBS := $(LIBS:%=$B/%)

BUILD_FILES := \
    $B/Changes \
    $B/ReadMe.md \
    $B/package.json \

BUILD_DIRS := \
    $B/lib/testml/run \

#------------------------------------------------------------------------------
.PHONY: build
build:: \
    js-files \
    $(BUILD_DIRS) \
    $(BUILD_FILES) \
    $(ALL_LIBS)

publish:: check dist
	npm publish $(DIST)
	git push
	git tag $(TAG_PREFIX)-$(VERSION)
	git push --tag

dist:: $(DIST)

distdir:: $(DISTDIR)

clean::
	rm -fr $B $(DIST) $(DISTDIR)

realclean:: clean

include $(ROOT)/.makefile/package.mk

#------------------------------------------------------------------------------
$(BUILD_DIRS):
	mkdir -p $@

$B/%: $P/%
	cp $< $@

$B/lib/testml/%.js: lib/testml/%.js
	cp $< $@

$B/lib/testml/browser.js: $P/src/testml/browser.coffee force
	coffee -cp $< | perl -pe 's/^# include (.*)/`cat $$1`/e' > $@

force:

$(DIST): $B/$(DIST)
	mv $< $@

$(DISTDIR): $(DIST)
	tar xzf $<
	mv package $@
	rm -f $<

$B/$(DIST) $B/$(DISTDIR): build
	cd $B && npm pack
