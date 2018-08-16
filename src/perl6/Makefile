RUNTIME_LANG := perl6
ROOT := ../..

export PERL6LIB := $(ROOT)/ext/perl6

#------------------------------------------------------------------------------
default:

test: test-tap

clean::
	find . | grep '\.precomp' | xargs rm -fr

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
