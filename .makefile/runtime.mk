export TESTML_ROOT := $(shell cd $(ROOT) && pwd)
export MAKE

EXT := $(ROOT)/ext/$(RUNTIME_LANG)
NODE_MODULES := $(ROOT)/src/node_modules

TESTML_COMPILER_LANG ?= perl

ifeq ($(TESTML_COMPILER_LANG),coffee)
TEST_TAP_DEPS += $(NODE_MODULES)
endif
ifeq ($(TESTML_COMPILER_LANG),perl)
export PERL5LIB := $(ROOT)/ext/perl
endif

# For coffee:
PATH := $(ROOT)/src/node_modules/.bin:$(PATH)
# For testml-* bins:
PATH := $(ROOT)/bin:$(PATH)
export PATH

export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

test ?= test/*.tml
j = 1

prove_opts = -v
ifneq ($j,1)
prove_opts += -j$j
endif

#------------------------------------------------------------------------------
test-tap:: $(EXT) $(TEST_TAP_DEPS)
	TESTML_RUN=$(RUNTIME_LANG)-tap prove $(prove_opts) $(test)

$(EXT):
	$(MAKE) -C $(ROOT) ext/$(RUNTIME_LANG)

$(NODE_MODULES):
	$(MAKE) -C $(ROOT) src/node_modules

clean::
	rm -fr ./test/.testml $(ROOT)/test/runtime-tml/.testml
	find . -type f | grep -E '\.(swp|swo)$$' | xargs rm -f

realclean:: clean
	rm -fr $(ROOT)/src/node_modules

SHELL = bash
