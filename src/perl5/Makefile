RUNTIME_LANG := perl5
ROOT := ../..

#------------------------------------------------------------------------------
default:

test: test-tap

cover: cover-delete
	PERL5OPT="-MDevel::Cover=+ignore,local,+ignore,^t/,+ignore,^xt/,+ignore,.*/prove" make test
	cover

# will remove cover_db directory
cover-delete:
	cover -delete

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
include pkg/package.mk
