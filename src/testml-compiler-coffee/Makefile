export ROOT := ../..
export TESTML_COMPILER_TEST := $(ROOT)/test/compiler-tml

NODE_MODULES := $(ROOT)/src/node_modules

# Build up PATH (in reverse order):

# XXX For npm-check-release
PATH := $(ROOT)/.bin:$(PATH)
# For testml-switch
PATH := $(TESTML_COMPILER_TEST)/bin:$(PATH)
# For testml-perl5-tap
PATH := $(ROOT)/bin:$(PATH)
# For coffee
PATH := $(NODE_MODULES)/.bin:$(PATH)
# For testml-compiler
PATH := $(PWD)/bin:$(PATH)
export PATH

export TAG_PREFIX := compiler

export TESTML_COMPILER_BOOTSTRAP := $(boot)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
default:

.PHONY: test
test: $(NODE_MODULES)
	NODE_PATH=lib PERL5LIB=$(ROOT)/ext/perl5:test prove -v -j$(j) $(test)

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
	rm -fr testml-compiler-*
	rm -f tmp-grammar
	rm -fr npm test/testml/.testml $(TESTML_COMPILER_TEST)/.testml

realclean:: clean
	rm -fr $(NODE_MODULES)

#------------------------------------------------------------------------------
$(NODE_MODULES):
	$(MAKE) -C $(ROOT) src/node_modules

#------------------------------------------------------------------------------
include pkg/package.mk

SHELL = bash
