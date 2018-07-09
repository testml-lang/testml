TOP := ../../..
export PATH := $(TOP)/compiler/coffee/bin:$(PATH)

NAME := $(shell grep '^name ' dist.ini | awk '{print $$3}')
VERSION := $(shell grep '^version ' dist.ini | awk '{print $$3}')
DISTDIR := $(NAME)-$(VERSION)
DIST := $(NAME)-$(VERSION).tar.gz
TAG_PREFIX := pkg-perl5

DOCS := $(shell find doc -type f)
LIBS := $(shell cd ..; find lib -type f)
TESTS := $(shell cd ../test; echo *.tml)
ALL_DOCS := $(DOCS:doc/%=lib/%)
ALL_LIBS := $(LIBS) lib/TestML.pm
ALL_TESTS := $(TESTS:%.tml=t/%.t) t/TestMLBridge.pm
INC_BIN := inc/bin/testml-cpan
INC_LIBS := $(LIBS:%=inc/%)
INC_TESTS := $(TESTS:%=inc/t/%.json)

build: \
    $(TOP)/compiler/coffee \
    $(TOP)/test/run-tml \
    lib/TestML/Run t inc/bin inc/lib/TestML/Run inc/t \
    $(ALL_DOCS) \
    $(ALL_LIBS) \
    $(ALL_TESTS) \
    $(INC_BIN) \
    $(INC_LIBS) \
    $(INC_TESTS)

lib/TestML/Run t inc/bin inc/lib/TestML/Run inc/t:
	mkdir -p $@

lib/TestML.pm: src/TestML.pm
	cp $< $@

lib/%: ../lib/%
	cp $< $@

lib/%.pod: doc/%.pod
	cp $< $@

t/%.t: ../test/%.tml
	cp $< $@
	perl -pi -e 's{#!/usr/bin/env testml}{#!inc/bin/testml-cpan}' $@

t/TestMLBridge.pm: ../test/TestMLBridge.pm
	cp $< $@

inc/bin/testml-cpan: ../bin/testml-cpan
	cp $< $@

inc/lib/TestML.pm: src/TestML.pm
	cp $< $@

inc/lib/%: ../lib/%
	cp $< $@

inc/t/%.tml.json: t/%.t
	testml-compiler $< > $@

clean:
	rm -fr inc lib t $(DIST) $(DISTDIR)

realclean: clean

$(TOP)/compiler/coffee:
	make -C $(TOP) compiler/coffee

$(TOP)/test/run-tml:
	make -C $(TOP) test/run-tml

#------------------------------------------------------------------------------
publish: check dist
	cpan-upload $(DIST)
	git push
	git tag $(TAG_PREFIX)-$(VERSION)
	git push --tag

dist: build
	dzil build

distdir: dist

check:
	@[ -z "`git status -s`" ] || { \
	    echo "Can't publish. Uncommited git changes"; \
	    exit 1 ; \
	}
