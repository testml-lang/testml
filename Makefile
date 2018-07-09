TOP := ../..
LANG := perl5

default: status

test: test-tap

include $(TOP)/.makefile/run.mk
include $(TOP)/.makefile/test-tap.mk
