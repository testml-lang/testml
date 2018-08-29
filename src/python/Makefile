RUNTIME_LANG := python
ROOT := ../..

#------------------------------------------------------------------------------
default:

test: test-tap test-unit

test-unit:
	testml-python-unit $(test)

clean::
	find . -name '*.pyc' | xargs rm -f

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
include pkg/package.mk
