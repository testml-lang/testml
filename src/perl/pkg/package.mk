export PATH := $(ROOT)/src/testml-compiler-perl/bin:$(PATH)
export PERL5LIB := $(ROOT)/ext/perl

B := build
P := pkg

NAME := $(shell grep '^name ' $P/dist.ini | awk '{print $$3}')
VERSION := $(shell grep '^version ' $P/dist.ini | awk '{print $$3}')
DISTDIR := $(NAME)-$(VERSION)
DIST := $(NAME)-$(VERSION).tar.gz
TAG_PREFIX := pkg-perl

BINS := bin/testml
DOCS := $(shell cd $P && find doc -type f)
LIBS := $(shell cd $P && find lib -type f)
TESTS := $(shell cd $P && find t -type f)
ALL_BINS := $(BINS:bin/%=$B/bin/%)
ALL_DOCS := $(DOCS:doc/%=$B/lib/%)
ALL_LIBS := $(LIBS:lib/%=$B/lib/%)
ALL_TESTS := $(TESTS:t/%=$B/t/%)

BUILD_FILES := \
    $B/Changes \
    $B/dist.ini \

BUILD_DIRS := \
    $B/bin \
    $B/lib \
    $B/t

#------------------------------------------------------------------------------
.PHONY: build
build:: \
    $(BUILD_DIRS) \
    $(BUILD_FILES) \
    $(ALL_BINS) \
    $(ALL_DOCS) \
    $(ALL_LIBS) \
    $(ALL_TESTS)

publish:: check dist
	cpan-upload $(DIST)
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

$B/bin/%: bin/%
	cp $< $@

$B/lib/%.pm: $P/lib/%.pm
	cp $< $@

$B/lib/%.pod: $P/doc/%.pod
	cp $< $@

$B/t/%.t: $P/t/%.tml
	cp $< $@

$(DIST): $B/$(DIST)
	mv $< $@
	rm -fr $B/$(DISTDIR)

$(DISTDIR): $B/$(DISTDIR)
	mv $< $@
	rm -f $B/$(DIST)

$B/$(DIST) $B/$(DISTDIR): build
	cd $B && dzil build
