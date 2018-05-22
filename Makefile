export TESTML_ROOT := $(PWD)
export PATH := $(TESTML_ROOT)/bin:$(PATH)

TAP_RUN := coffee node perl perl6 python
TAP_TESTS := $(TAP_RUN:%=test-%-tap)

COFFEE_FILES := $(shell find lib/coffee -type f) $(shell find test | grep -E '(\.coffee|/coffee/[0-9].*\.tml)')
JS_FILES := $(COFFEE_FILES:lib/coffee/%.coffee=lib/node/%.js)
JS_FILES := $(JS_FILES:test/%.coffee=test/%.js)
JS_FILES := $(subst coffee,node,$(JS_FILES))

WORKTREES := gh-pages node

test := test/*.tml

.PHONY: test
test: $(TAP_TESTS)

test-all: test test-out

# test-tap:
# 	TESTML_RUN=$(@:test-%=%) prove -v $(test)

test-perl-tap test-perl6-tap test-python-tap:
	TESTML_RUN=$(@:test-%=%) prove -v $(test)

test-coffee-tap: node_modules
ifndef tests
	TESTML_RUN=$(@:test-%=%) prove -v $(test) $(wildcard test/coffee/*.tml)
else
	TESTML_RUN=$(@:test-%=%) prove -v $(tests)
endif

test-node-tap: node_modules js-files
ifndef tests
	TESTML_RUN=$(@:test-%=%) prove -v $(test) $(wildcard test/node/*.tml)
else
	TESTML_RUN=$(@:test-%=%) prove -v $(tests)
endif

test-out:
	prove -v test/out/*.tml

node_modules:
	npm install --save-dev lodash diff
	rm -f package*

$(WORKTREES):
	git worktree add -f $@ $@

gh-pages-test: gh-pages
	make -C $< test

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
	rm -fr test/.testml/ test/out/.testml/
	rm -fr lib/perl6/.precomp/
	rm -fr $(WORKTREES)
	rm -fr node_modules/
	rm -f package*
	find . -name '*.pyc' | xargs rm
	git worktree prune
