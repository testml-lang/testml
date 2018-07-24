export ROOT := ../..
export TESTML_COMPILER_TEST := $(ROOT)/test/compiler-tml

export PATH := $(ROOT)/.bin:$(ROOT)/bin:$(TESTML_COMPILER_TEST)/bin:$(PWD)/bin:$(PATH)
export TAG_PREFIX := compiler

export TESTML_COMPILER_BOOTSTRAP := $(boot)
export TESTML_COMPILER_DEBUG := $(debug)

NODE_MODULES := $(ROOT)/src/node_modules

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
default:

.PHONY: test
test: $(NODE_MODULES)
	NODE_PATH=lib PERL5LIB=test prove -v -j$(j) $(test)

update: update-grammar

update-grammar: $(NODE_MODULES)
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
	rm -fr $(NODE_MODULES)

#------------------------------------------------------------------------------
$(NODE_MODULES):
	make -C $(ROOT) src/node_modules

#------------------------------------------------------------------------------
include pkg/package.mk
