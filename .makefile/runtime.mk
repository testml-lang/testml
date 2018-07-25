export TESTML_ROOT := $(ROOT)

EXT := $(ROOT)/ext
NODE_MODULES := $(ROOT)/src/node_modules

TESTML_COMPILER_LANG ?= perl5

ifeq ($(TESTML_COMPILER_LANG),coffee)
TEST_TAP_DEPS += $(NODE_MODULES)
endif
ifeq ($(TESTML_COMPILER_LANG),perl5)
export PERL5LIB := $(ROOT)/ext/perl5
endif

export PATH := $(PWD)/bin:$(ROOT)/bin:$(ROOT)/src/node_modules/.bin:$(ROOT)/src/testml-compiler-$(TESTML_COMPILER_LANG)/bin:$(PATH)
export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
test-tap:: $(EXT) $(TEST_TAP_DEPS)
	TESTML_RUN=$(LANG)-tap prove -v -j$(j) $(test)

$(EXT):
	make -C $(ROOT) ext

$(NODE_MODULES):
	make -C $(ROOT) src/node_modules

clean::
	rm -fr $(ROOT)/test/run-tml/.testml
	find . -type f | grep -E '\.(swp|swo)$$' | xargs rm -f

realclean:: clean
	rm -fr $(ROOT)/src/node_modules
