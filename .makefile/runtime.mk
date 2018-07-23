export TESTML_ROOT := $(ROOT)

TESTML_COMPILER_LANG ?= perl5

ifeq ($(TESTML_COMPILER_LANG),coffee)
TEST_TAP_DEPS += ../node_modules
endif

export PATH := $(ROOT)/bin:$(PWD)/bin:$(ROOT)/src/testml-compiler-$(TESTML_COMPILER_LANG)/bin:$(PATH)
export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
test-tap:: $(TEST_TAP_DEPS)
	TESTML_RUN=$(LANG)-tap prove -v -j$(j) $(test)

../node_modules:
	git branch --track node_modules origin/node_modules 2>/dev/null || true
	git worktree add -f $@ node_modules

clean::
	rm -fr $(ROOT)/test/run-tml/.testml
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f

realclean:: clean
	rm -fr $(ROOT)/src/node_modules
