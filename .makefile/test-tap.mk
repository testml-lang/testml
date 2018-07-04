define HELP

    make test           - Run all tests
    make test-tap       - Run all TAP tests
    clean               - Remove generated files

endef
export HELP

TOP := $(shell cd ../.. && pwd)
RUN_LANG := $(shell basename `pwd`)

export TESTML_ROOT := $(TOP)
export TESTML_RUN_ROOT := $(TOP)/run/$(RUN_LANG)
export TESTML_COMPILER_ROOT := $(TOP)/compiler/coffee
export PATH := $(TESTML_RUN_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
help::
	@echo "$$HELP"

test-tap:: $(TOP)/test/run-tml compiler
	TESTML_RUN=$(RUN_LANG)-tap prove -v -j$(j) $(test)

compiler::
ifeq ($(shell which testml-compiler),)
	make $(TESTML_COMPILER_ROOT)
endif

$(TESTML_COMPILER_ROOT)::
	cd $(TOP) && make compiler/coffee
	cd $(TESTML_COMPILER_ROOT) && make node_modules

$(TOP)/test/run-tml::
	cd $(TOP) && make test/run-tml

node_modules:
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@

clean::
	rm -fr $(TOP)/test/run-tml/.testml
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f

realclean:: clean
	rm -fr node_modules
