export ROOT := ../..
export TESTML_COMPILER_TEST := $(ROOT)/test/compiler-tml

export PATH := $(ROOT)/.bin:$(ROOT)/bin:$(TESTML_COMPILER_TEST)/bin:$(PWD)/bin:$(PATH)
export TAG_PREFIX := compiler

export TESTML_COMPILER_BOOTSTRAP := $(boot)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

STATUS := \
    compiler-tml \
    pegex \
    test/testml \

#------------------------------------------------------------------------------
default:

.PHONY: test
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

clean::
	rm -fr remove testml-compiler-*
	rm -f tmp-grammar
	rm -fr npm test/testml/.testml

realclean:: clean
	rm -fr node_modules pegex
	git worktree prune

include ../../.makefile/status.mk
NPM_BUILD_DEPS := node_modules $(TESTML_COMPILER_TEST)
include pkg/package.mk
