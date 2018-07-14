export TESTML_ROOT := $(ROOT)
export TESTML_RUN_ROOT := $(ROOT)/run/$(LANG)
export TESTML_COMPILER_ROOT := $(ROOT)/compiler/coffee

export PATH := $(TESTML_RUN_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

#------------------------------------------------------------------------------
compiler::
ifeq ($(shell which testml-compiler),)
	make $(TESTML_COMPILER_ROOT)
endif

#------------------------------------------------------------------------------
$(TESTML_COMPILER_ROOT)::
	cd $(ROOT) && make compiler/coffee
	cd $(TESTML_COMPILER_ROOT) && make node_modules

