TOP := $(shell cd ../.. && pwd)
export TESTML_ROOT := $(TOP)
export TESTML_RUN_ROOT := $(TOP)/run/node
export TESTML_COMPILER_ROOT := $(TOP)/compiler/coffee
export PATH := $(TESTML_RUN_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
default:

test: test-tap

test-tap: $(TOP)/test/run-tml compiler node_modules
	TESTML_RUN=node-tap prove -v -j$(j) $(test)

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

# export TESTML_ROOT := $(PWD)/..
# export PATH := $(TESTML_COMPILER_ROOT)/bin:$(PATH)
# export TAG_PREFIX := node
# 
# #------------------------------------------------------------------------------
# NODE_MODULES_DIR := node_modules
# INGY_NPM := ../../../ingy-npm
# 
# ifneq ($(wildcard $(INGY_NPM)),)
#     include $(INGY_NPM)/share/ingy-npm.mk
# else
#     $(warning Error: $(INGY_NPM) does not exist)
#     $(warning Try: git clone git@github.com:ingydotnet/ingy-npm $(INGY_NPM))
#     $(error Fix your errors)
# endif
# 
# #------------------------------------------------------------------------------
# test = test/*.tml
# 
# test: $(NODE_MODULES_DIR)
# 	NODE_PATH=lib prove -v $(test)
# 
# $(NODE_MODULES_DIR):
# 	git branch --track $@ origin/$@ 2>/dev/null || true
# 	git worktree add -f $@ $@
# 
# clean:
# 	rm -fr npm testml-*.tgz
# 
# realclean: clean
# 	rm -fr node_modules
