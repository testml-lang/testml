export TESTML_ROOT := $(PWD)
export PATH := $(TESTML_ROOT)/bin:$(PATH)

TAP_RUNNERS := coffee-tap node-tap perl-tap perl6-tap python-tap
TAP_TESTS := $(TAP_RUNNERS:%=test-%)

COFFEE_FILES := $(shell find lib/coffee -type f) test/testml-bridge.coffee
JS_FILES := $(COFFEE_FILES:lib/coffee/%.coffee=lib/node/%.js)
JS_FILES := $(JS_FILES:test/%.coffee=test/%.js)

WORKTREES := gh-pages node

test := test/*.tml

.PHONY: test
test: $(TAP_TESTS) test-out

test-all: test test-out

# test-tap:
# 	TESTML_RUN=$(@:test-%=%) prove -v $(test)

test-perl-tap test-perl6-tap test-python-tap:
	TESTML_RUN=$(@:test-%=%) prove -v $(test)

test-coffee-tap: node_modules # test-tap
	TESTML_RUN=$(@:test-%=%) prove -v $(test)

test-node-tap: node_modules js-files # test-tap
	TESTML_RUN=$(@:test-%=%) prove -v $(test)

test-out:
	prove -v test/out/*.tml

node_modules:
	npm install --save-dev lodash
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

clean:
	rm -fr test/.testml/ test/out/.testml/
	rm -fr lib/perl6/.precomp/
	rm -fr $(WORKTREES)
	rm -fr node_modules/
	rm -f package*
	find . -name '*.pyc' | xargs rm
	git worktree prune
