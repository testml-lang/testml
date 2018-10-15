RUNTIME_LANG := elixir
ROOT := ../..
TEST_TAP_DEPS := $(ROOT)/src/node_modules deps _build

#------------------------------------------------------------------------------
default:

test: test-tap

deps _build:
	mix deps.get

clean::
	rm -f mix.lock
	rm -fr _build

realclean::
	rm -fr deps

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
