RUNTIME_LANG := elixir
ROOT := ../..
TEST_TAP_DEPS := $(ROOT)/src/node_modules

#------------------------------------------------------------------------------
default:

test: test-tap

clean::
	rm -f mix.lock
	rm -fr _build

realclean::
	rm -fr deps

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
