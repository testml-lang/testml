export TESTML_ROOT := $(PWD)
export TESTML_COMPILER_ROOT := $(PWD)/compiler
export PATH := $(TESTML_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

LANG_ALL := coffee node perl5 perl6 python
LANG_ALL := coffee perl5 perl6 python
TEST_ALL := $(LANG_ALL:%=test-%)

# COFFEE_FILES := $(shell find lib/coffee -type f | grep -v '\.swp$$') $(shell find test | grep -E '\.coffee$$' | grep -v '\.swp$$')
# JS_FILES := $(COFFEE_FILES:lib/coffee/%.coffee=lib/node/%.js)
# JS_FILES := $(JS_FILES:test/%.coffee=test/%.js)
# JS_FILES := $(subst coffee,node,$(JS_FILES))

# xALL_LANG := node perl5 perl6
# RUN := $(xALL_LANG:%=run/%)
# PKG := $(xALL_LANG:%=pkg/%)
# EXE := $(xALL_LANG:%=exe/%)

PKG := pkg-node
RUN := run/coffee run/node run/perl5 run/perl6 run/python

WORK := \
    compiler/coffee \
    eg/rotn \
    note \
    $(PKG) \
    $(RUN) \
    site \
    talk \

STATUS := $(WORK) \
    test/run-tml

export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)
j = 1

include .makefile/status.mk

.PHONY: test
test: $(TEST_ALL)

test-%: run/%
	make -C $< test

test-travis: test-tap test-output-travis

test-tap: $(TAP_TESTS)

test-unit: $(UNIT_TESTS)

test-all: test test-output

test-output:
ifdef test
	prove -v -j$(j) $(test)
else
	prove -v -j$(j) test/output/*.tml
endif

test-output-travis:
	testml-python-unit \
	test/python/testml/0{6,7,9}0*.tml \
	test/python/testml/1*.tml

work: $(WORK)

$(WORK) orphan:
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $(subst -,/,$@) $@

test/run-tml:
	git branch --track run-tml origin/run-tml 2>/dev/null || true
	git worktree add -f $@ run-tml

npm: node js-files
	(cd $<; make clean npm)

# js-files: $(JS_FILES)

lib/node/%.js: lib/coffee/%.coffee
	coffee -cp $< > $@

test/%.js: test/%.coffee
	coffee -cp $< > $@

test/node/%.js: test/coffee/%.coffee
	coffee -cp $< > $@

clean:
	rm -f package*
	find . -type d | grep '\.testml$$' | xargs rm -fr
	find . -type d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f

realclean: clean
	rm -fr $(WORK) test/run-tml
	git worktree prune
	rm -fr compiler eg pkg run
