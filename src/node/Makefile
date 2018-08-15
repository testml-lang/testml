LANGUAGE := node
ROOT := ../..

ALL_JS := \
    lib/testml/index.js \
    lib/testml/bridge.js \
    lib/testml/run.js \
    lib/testml/stdlib.js \
    lib/testml/run/mocha.js \
    lib/testml/run/tap.js \

TEST_TAP_DEPS := $(ROOT)/src/node_modules js-files

#------------------------------------------------------------------------------
default:

test: test-tap

clean::
	rm -fr lib

#------------------------------------------------------------------------------
js-files: lib/testml/run $(ALL_JS)

lib/testml/run:
	mkdir -p $@

lib/testml/%.js: ../coffee/lib/testml/%.coffee
	coffee -cp $< > $@

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
include pkg/package.mk
