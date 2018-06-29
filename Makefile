export TESTML_ROOT := $(shell cd $(PWD)/../.. && pwd)
export TESTML_COMPILER_ROOT := $(PWD)
export TESTML_COMPILER_TEST := $(TESTML_ROOT)/test/compiler-tml

export PATH := $(TESTML_ROOT)/bin:$(TESTML_COMPILER_TEST)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)
export TAG_PREFIX := compiler

export TESTML_COMPILER_BOOTSTRAP := $(boot)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/testml/[0-9]*.tml

STATUS := \
    compiler-tml \
    pegex \
    test/testml \

include ../../.makefile/status.mk

#------------------------------------------------------------------------------
test: node_modules $(TESTML_COMPILER_TEST)
	NODE_PATH=lib PERL5LIB=test prove -v -j$(j) $(test)

update: update-grammar

update-grammar: node_modules pegex
	( \
	set -o pipefail; \
	grep -B99 make_tree lib/testml-compiler/grammar.coffee; \
	TESTML_COMPILER_GRAMMAR_PRINT=1 \
	    ./bin/testml-compiler Makefile \
	    | sed 's/^/    /' \
	) > tmp-grammar
	mv tmp-grammar lib/testml-compiler/grammar.coffee

node_modules pegex:
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@

$(TESTML_COMPILER_TEST):
	make -C $(TESTML_ROOT) test/compiler-tml

clean:
	rm -fr remove testml-compiler-*
	rm -f tmp-grammar
	rm -fr npm test/testml/.testml

realclean: clean
	rm -fr node_modules pegex
	git worktree prune



### XXX Make this work without ingy-npm
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
