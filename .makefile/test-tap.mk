ifeq ($(ROOT),)
    $(error ROOT not set in Makefile)
endif

#------------------------------------------------------------------------------
export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
test-tap:: $(ROOT)/test/run-tml compiler $(TEST_TAP_DEPS)
	TESTML_RUN=$(LANG)-tap prove -v -j$(j) $(test)

clean::
	rm -fr $(ROOT)/test/run-tml/.testml
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f

realclean:: clean
	rm -fr node_modules

#------------------------------------------------------------------------------
$(ROOT)/test/run-tml::
	cd $(ROOT) && make test/run-tml

node_modules:
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@
