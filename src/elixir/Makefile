RUNTIME_LANG := elixir
ROOT := ../..
TEST_TAP_DEPS := $(ROOT)/src/node_modules deps

#------------------------------------------------------------------------------
default:

test: test-tap

deps:
	mix deps.get

clean::
	rm -f mix.lock
	rm -fr _build

realclean::
	rm -fr deps

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
