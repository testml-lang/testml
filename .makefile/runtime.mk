export TESTML_ROOT := $(ROOT)

export PATH := $(ROOT)/bin:$(ROOT)/src/$(LANG)/bin:$(ROOT)/src/testml-compiler-coffee/bin:$(PATH)
export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
test-tap:: $(TEST_TAP_DEPS) ../node_modules
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
