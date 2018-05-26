INGY_NPM := ../../ingy-npm
export TESTML_ROOT := $(PWD)/..
export PATH := $(TESTML_COMPILER_ROOT)/bin:$(PATH)
export TAG_PREFIX := node

ifneq ($(wildcard $(INGY_NPM)),)
    include $(INGY_NPM)/share/ingy-npm.mk
else
    $(warning Error: $(INGY_NPM) does not exist)
    $(warning Try: git clone git@github.com:ingydotnet/ingy-npm $(INGY_NPM))
    $(error Fix your errors)
endif

test = test/*.tml

test: node_modules
	NODE_PATH=lib prove -v $(test)

clean: ingy-npm-clean
	rm -fr node_modules
