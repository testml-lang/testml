LANG := node
ROOT := ../..

ALL_JS := \
    lib/testml/index.js \
    lib/testml/bridge.js \
    lib/testml/run.js \
    lib/testml/stdlib.js \
    lib/testml/run/mocha.js \
    lib/testml/run/tap.js \

TEST_TAP_DEPS := js-files ../node_modules

#------------------------------------------------------------------------------
default:

test: test-tap

realclean::
	rm -fr lib

#------------------------------------------------------------------------------
js-files: ../coffee lib/testml/run $(ALL_JS)

lib/testml/run:
	mkdir -p $@

lib/testml/%.js: ../coffee/lib/testml/%.coffee
	coffee -cp $< > $@

lib/testml/index.js: pkg/src/testml/index.coffee

../coffee:
	cd $(ROOT) && make run/coffee

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
include pkg/package.mk
