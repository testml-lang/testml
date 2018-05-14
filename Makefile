TAP_RUNNERS := coffee-tap node-tap perl-tap perl6-tap
TAP_TESTS := $(TAP_RUNNERS:%=test-%)

COFFEE_FILES := $(shell find lib/coffee -type f) test/testml-bridge.coffee
JS_FILES := $(COFFEE_FILES:lib/coffee/%.coffee=lib/node/%.js)
JS_FILES := $(JS_FILES:test/%.coffee=test/%.js)

test := test/*.tml

.PHONY: test
test: node_modules $(TAP_TESTS)

test-all: test
	./test/test-cli.sh

# test-tap:
# 	(. .rc; TESTML_RUN=$(@:test-%=%) prove -v $(test))

test-perl-tap test-perl6-tap:
	(. .rc; TESTML_RUN=$(@:test-%=%) prove -v $(test))

test-coffee-tap: node_modules # test-tap
	(. .rc; TESTML_RUN=$(@:test-%=%) prove -v $(test))

test-node-tap: node_modules js-files # test-tap
	(. .rc; TESTML_RUN=$(@:test-%=%) prove -v $(test))

node_modules:
	npm install --save-dev lodash

node:
	git worktree add -f $@ $@

npm: node js-files
	(cd $<; make clean npm)

js-files: $(JS_FILES)

lib/node/%.js: lib/coffee/%.coffee
	coffee -cp $< > $@

test/%.js: test/%.coffee
	coffee -cp $< > $@

clean:
	rm -fr test/.testml/
	rm -fr lib/perl6/.precomp/
	rm -fr node/
	rm -fr node_modules/
	rm -f package*
	git worktree prune
