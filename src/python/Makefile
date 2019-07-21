RUNTIME_LANG := python
ROOT := ../..

test := test/[0-9]*.tml test/inline-bridge.tml

#------------------------------------------------------------------------------
default:

test: test-tap test-output test-unit

test-output:
# XXX These were breaking on systems without `python` binary in PATH
# 	TESTML_RUN=$(RUNTIME_LANG)-tap prove $(prove_opts) \
# 	    test/test-output.tml

test-unit:
	testml-python-unit $(test)

clean::
	find . -name '*.pyc' | xargs rm -f

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
include package.mk
