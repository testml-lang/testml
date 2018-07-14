ifeq ($(ROOT),)
    $(error ROOT not set in Makefile)
endif

#------------------------------------------------------------------------------
export PATH := $(ROOT)/compiler/coffee/bin:$(PATH)

B := build
P := pkg

NAME := $(shell grep '^ *name=' $P/setup.py | cut -d"'" -f2)
VERSION := $(shell grep '^ *version=' $P/setup.py | cut -d"'" -f2)
DISTDIR := $(NAME)-$(VERSION)
DIST := $(NAME)-$(VERSION).tar.gz
TAG_PREFIX := pkg-python

LIBS := $(shell find lib -type f | grep '\.py$$')
ALL_LIBS := $(LIBS:lib/%=$B/%)

BUILD_FILES := \
    $B/LICENSE \
    $B/ReadMe.md \
    $B/setup.py \

BUILD_DIRS := \
    $B/testml/run \
    $B/tests \

#------------------------------------------------------------------------------
build:: \
    $(ROOT)/compiler/coffee \
    $(ROOT)/test/run-tml \
    $(BUILD_DIRS) \
    $(BUILD_FILES) \
    $(ALL_LIBS)

clean::
	rm -fr $B $(DIST) $(DISTDIR)

realclean:: clean

publish: check dist
	twine upload $(DIST)
	git push
	git tag $(TAG_PREFIX)-$(VERSION)
	git push --tag

dist: build
	cd build && python setup.py sdist
	rm -fr $B/testml.egg-info
	mv $B/dist/$(DIST) .
	rmdir $B/dist

distdir: dist
	tar xzf $(DIST)
	rm -f $(DIST)

check:
	@[ -z "`git status -s`" ] || { \
	    echo "Can't publish. Uncommited git changes"; \
	    exit 1 ; \
	}

#------------------------------------------------------------------------------
$B/testml/run $B/tests:
	mkdir -p $@

$B/%: $P/%
	cp $< $@

$B/testml/%: lib/testml/%
	cp $< $@

$B/tests/%.tml: test/%.tml
	cp $< $@

$B/tests/testml-bridge.py: test/testml-bridge.py
	cp $< $@
