LANG := perl6
ROOT := ../..

#------------------------------------------------------------------------------
default:

test: test-tap

clean::
	find . | grep '\.precomp' | xargs rm -fr

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/run.mk
include ../../.makefile/test-tap.mk
