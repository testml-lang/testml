export TESTML_ROOT := $(ROOT)

TESTML_COMPILER_LANG ?= perl5

ifeq ($(TESTML_COMPILER_LANG),coffee)
TEST_TAP_DEPS += ../node_modules
endif

export PATH := $(ROOT)/bin:$(PWD)/bin:$(ROOT)/src/testml-compiler-$(TESTML_COMPILER_LANG)/bin:$(PATH)
export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

NODE_MODULES := $(ROOT)/src/node_modules

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
test-tap:: $(TEST_TAP_DEPS)
	TESTML_RUN=$(LANG)-tap prove -v -j$(j) $(test)

$(NODE_MODULES):
	make -C $(ROOT) src/node_modules

clean::
	rm -fr $(ROOT)/test/run-tml/.testml
	find . -type f | grep -E '\.(swp|swo)$$' | xargs rm -f

realclean:: clean
	rm -fr $(ROOT)/src/node_modules
