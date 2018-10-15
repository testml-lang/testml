RUNTIME_LANG := go
ROOT := ../..

#------------------------------------------------------------------------------
default:

.PHONY: test
test: test-tap

clean::
	rm -fr test/.testml $(ROOT)/test/runtime-tml/.testml

#------------------------------------------------------------------------------
include $(ROOT)/.makefile/runtime.mk
