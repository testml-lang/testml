INGY_NPM := ../../ingy-npm

export TESTML_COMPILER_ROOT := $(PWD)
export TESTML_COMPILER_TEST := $(shell cd $(PWD)/../compiler-tml && pwd)
export TESTML_ROOT := $(shell cd $(PWD)/.. && pwd)

export PATH := $(TESTML_ROOT)/bin:$(TESTML_COMPILER_TEST)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)
export TAG_PREFIX := compiler

ifneq ($(wildcard $(INGY_NPM)),)
    include $(INGY_NPM)/share/ingy-npm.mk
else
    $(warning Error: $(INGY_NPM) does not exist)
    $(warning Try: git clone git@github.com:ingydotnet/ingy-npm $(INGY_NPM))
    $(error Fix your errors)
endif

j = 1
test = test/testml/[0-9]*.tml
export TESTML_COMPILER_BOOTSTRAP := $(boot)
export TESTML_COMPILER_DEBUG := $(debug)

test: node_modules ../compiler-tml
	NODE_PATH=lib PERL5LIB=test prove -v -j$(j) $(test)

test-pegex: node_modules ../pegex-js/npm
	rm -fr node_modules/pegex
	NODE_PATH=lib:../pegex-js/npm/lib prove -lv test/

update: update-grammar

update-grammar: node_modules ../pegex
	( \
	set -o pipefail; \
	grep -B99 make_tree lib/testml-compiler/grammar.coffee; \
	TESTML_COMPILER_GRAMMAR_PRINT=1 \
            ./bin/testml-compiler Makefile \
            | sed 's/^/    /' \
	) > tmp-grammar
	mv tmp-grammar lib/testml-compiler/grammar.coffee

../pegex ../compiler-tml:
	(cd ..; make $(@:../%=%))

clean: ingy-npm-clean
	rm -fr node_modules
	rm -f tmp-grammar
	rm -fr test/testml/.testml
