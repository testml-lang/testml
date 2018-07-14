LANG := python
ROOT := ../..

#------------------------------------------------------------------------------
default:

test: test-tap test-unit

test-unit: $(ROOT)/test/run-tml compiler
	testml-python-unit $(test)

clean::
	find . -name '*.pyc' | xargs rm -f

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/run.mk
include $(ROOT)/.makefile/test-tap.mk
include pkg/package.mk
