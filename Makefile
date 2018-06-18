export TESTML_ROOT := $(PWD)
export TESTML_COMPILER_ROOT := $(PWD)/compiler
export PATH := $(TESTML_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

ALL_LANG := coffee node perl5 perl6 python
TAP_RUN := $(ALL_LANG)
TAP_TESTS := $(TAP_RUN:%=test-%-tap)
UNIT_RUN := python
UNIT_TESTS := $(UNIT_RUN:%=test-%-unit)

COFFEE_FILES := $(shell find lib/coffee -type f | grep -v '\.swp$$') $(shell find test | grep -E '\.coffee$$' | grep -v '\.swp$$')
JS_FILES := $(COFFEE_FILES:lib/coffee/%.coffee=lib/node/%.js)
JS_FILES := $(JS_FILES:test/%.coffee=test/%.js)
JS_FILES := $(subst coffee,node,$(JS_FILES))

xALL_LANG := node perl5 perl6
RUN := $(xALL_LANG:%=run-%)
PKG := $(xALL_LANG:%=pkg-%)
EXE := $(xALL_LANG:%=exe-%)

#     $(EXE) $(PKG) $(RUN) \

WORK := \
    exe-perl5 pkg-node run-perl5 \
    compiler \
    compiler-tml \
    gh-pages \
    node \
    node_modules \
    orphan \
    pegex \
    playground \
    rotn \
    site \
    talk/openwest-2018 \
    talk/tpc-2018 \
    testml-tml \

STATUS := $(WORK) \
    test/testml

export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)
j = 1

include .makefile/status.mk

.PHONY: test
test: test-tap test-unit

test-travis: test-tap test-output
	# XXX test-unit is failing on travis at the moment

test-tap: $(TAP_TESTS)

test-unit: $(UNIT_TESTS)

test-all: test test-output

test-coffee-tap test-node-tap: test/testml compiler node_modules js-files
ifdef test
	TESTML_RUN=$(@:test-%=%) prove -v -j$(j) $(test)
else
	TESTML_RUN=$(@:test-%=%) prove -v -j$(j) test/$(subst -tap,,$(subst test-,,$@))/testml/*.tml
endif

test-perl5-tap test-perl6-tap test-python-tap: test/testml compiler node_modules
ifdef test
	TESTML_RUN=$(@:test-%=%) prove -v -j$(j) $(test)
else
	TESTML_RUN=$(@:test-%=%) prove -v -j$(j) test/$(subst -tap,,$(subst test-,,$@))/testml/*.tml
endif

test-python-unit: test/testml
ifdef test
	testml-python-unit $(test)
else
	testml-python-unit \
	test/python/testml/0{6,7,9}0*.tml \
	test/python/testml/1*.tml
endif


test-output:
ifdef test
	prove -v -j$(j) $(test)
else
	prove -v -j$(j) test/output/*.tml
endif

work: $(WORK)

$(WORK):
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@

test/testml:
	git branch --track testml-tml origin/testml-tml 2>/dev/null || true
	git worktree add -f $@ testml-tml

npm: node js-files
	(cd $<; make clean npm)

js-files: $(JS_FILES)

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
	find . -name '*.pyc' | xargs rm -f

realclean: clean
	rm -fr $(WORK) test/testml
	git worktree prune
