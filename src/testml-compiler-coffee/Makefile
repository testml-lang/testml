export ROOT := ../..
export TESTML_COMPILER_TEST := $(ROOT)/test/compiler-tml

export PATH := $(ROOT)/.bin:$(ROOT)/bin:$(TESTML_COMPILER_TEST)/bin:$(PWD)/bin:$(PATH)
export TAG_PREFIX := compiler

export TESTML_COMPILER_BOOTSTRAP := $(boot)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
default:

.PHONY: test
test: ../node_modules
	NODE_PATH=lib PERL5LIB=test prove -v -j$(j) $(test)

update: update-grammar

update-grammar: ../node_modules
	( \
	set -o pipefail; \
	grep -B99 make_tree lib/testml-compiler/grammar.coffee; \
	TESTML_COMPILER_GRAMMAR_PRINT=1 \
	    ./bin/testml-compiler Makefile \
	    | sed 's/^/    /' \
	) > tmp-grammar
	mv tmp-grammar lib/testml-compiler/grammar.coffee

clean::
	rm -fr remove testml-compiler-*
	rm -f tmp-grammar
	rm -fr npm test/testml/.testml

realclean:: clean
	rm -fr ../node_modules

#------------------------------------------------------------------------------
../node_modules:
	git branch --track node_modules origin/node_modules 2>/dev/null || true
	git worktree add -f $@ node_modules

include pkg/package.mk
