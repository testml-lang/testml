TOP := $(shell cd ../.. && pwd)
export TESTML_ROOT := $(TOP)
export TESTML_RUN_ROOT := $(TOP)/run/perl6
export TESTML_COMPILER_ROOT := $(TOP)/compiler/coffee
export PATH := $(TESTML_RUN_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
default:

test: test-tap

test-tap: $(TOP)/test/run-tml compiler
	TESTML_RUN=perl6-tap prove -v -j$(j) $(test)

compiler:
ifeq ($(shell which testml-compiler),)
	make $(TESTML_COMPILER_ROOT)
endif

$(TESTML_COMPILER_ROOT):
	cd $(TOP) && make compiler/coffee
	cd $(TESTML_COMPILER_ROOT) && make node_modules

$(TOP)/test/run-tml:
	cd $(TOP) && make test/run-tml

clean:
	rm -fr $(TOP)/test/run-tml/.testml
	find . | grep '\.precomp' | xargs rm -fr
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f
