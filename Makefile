TOP := $(shell cd ../.. && pwd)
export TESTML_ROOT := $(TOP)
export TESTML_RUN_ROOT := $(TOP)/run/coffee
export TESTML_COMPILER_ROOT := $(TOP)/compiler/coffee
export PATH := $(TESTML_RUN_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
default:

test: test-tap

test-tap: $(TOP)/test/run-tml compiler node_modules
	TESTML_RUN=coffee-tap prove -v -j$(j) $(test)

compiler:
ifeq ($(shell which testml-compiler),)
	make $(TESTML_COMPILER_ROOT)
endif

$(TESTML_COMPILER_ROOT):
	cd $(TOP) && make compiler/coffee
	cd $(TESTML_COMPILER_ROOT) && make node_modules

$(TOP)/test/run-tml:
	cd $(TOP) && make test/run-tml

node_modules:
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@

clean:
	rm -fr $(TOP)/test/run-tml/.testml
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f

realclean: clean
	rm -fr node_modules
