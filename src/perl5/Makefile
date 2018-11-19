RUNTIME_LANG := perl5
ROOT := ../..

#------------------------------------------------------------------------------
default:

test: test-tap

cover:
	PERL5OPT="-MDevel::Cover=+ignore,local,+ignore,^t/,+ignore,^xt/,+ignore,.*/prove" make test
	cover

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
include pkg/package.mk
