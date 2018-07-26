B := build
P := pkg

NAME ?= $(shell grep '^  "name":' $P/package.json | cut -d'"' -f4)
VERSION ?= $(shell grep '^  "version":' $P/package.json | cut -d'"' -f4)
DISTDIR := $(NAME)-$(VERSION)
DIST := $(DISTDIR).tgz
TAG_PREFIX := compiler-node

LIBS := \
	lib/testml-compiler/index.coffee \
	lib/testml-compiler/ast.coffee \
	lib/testml-compiler/compiler.coffee \
	lib/testml-compiler/grammar.coffee \
	lib/testml-compiler/browser.coffee \

BINS := bin/testml-compiler

ALL_LIBS := $(LIBS:%.coffee=$B/%.js)
ALL_BINS := $(BINS:%=$B/%)

BUILD_FILES := \
    $B/Changes \
    $B/ReadMe.md \
    $B/package.json \

BUILD_DIRS := \
    $B/bin \
    $B/lib/testml-compiler \

#------------------------------------------------------------------------------
.PHONY: build
build:: \
    $(NODE_MODULES) \
    $(BUILD_DIRS) \
    $(BUILD_FILES) \
    $(ALL_BINS) \
    $(ALL_LIBS)

publish:: check dist
	npm publish $(DIST)
	git tag $${TAG_PREFIX:+$$TAG_PREFIX-}$(VERSION)
	git push --tag
	rm $(DIST)

dist:: $(DIST)

distdir:: $(DISTDIR)

install:: dist
	npm install -g $(DIST)
	rm -f $(DIST)

clean::
	rm -fr $B $(DIST) $(DISTDIR)

realclean:: clean

#------------------------------------------------------------------------------
$(BUILD_DIRS):
	mkdir -p $@

$B/%: $P/%
	cp $< $@

$B/bin/%: bin/%
	echo "#!/usr/bin/env node" > $@
	coffee -cp $< >> $@
	chmod +x $@

$B/lib/testml-compiler/%.js: lib/testml-compiler/%.coffee
	coffee -cp $< > $@

$B/lib/testml-compiler/browser.js: lib/testml-compiler/browser.coffee force
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

check::
	PATH=$$PATH VERSION=$(VERSION) npm-check-release
