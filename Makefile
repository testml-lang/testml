test-tap:: node_modules

include ../../.makefile/test-tap.mk

default: help

test: test-tap





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
