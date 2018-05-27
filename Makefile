INGY_NPM := ../../ingy-npm
export TESTML_COMPILER_ROOT := $(PWD)
export TESTML_ROOT := $(shell cd $(PWD)/.. && pwd)
export PATH := "$(TESTML_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)"
export TAG_PREFIX := compiler

ifneq ($(wildcard $(INGY_NPM)),)
    include $(INGY_NPM)/share/ingy-npm.mk
else
    $(warning Error: $(INGY_NPM) does not exist)
    $(warning Try: git clone git@github.com:ingydotnet/ingy-npm $(INGY_NPM))
    $(error Fix your errors)
endif

test = test/[0-9]*.tml
debug =
boot =

test: node_modules
	NODE_PATH=lib TESTML_COMPILER_BOOTSTRAP=$(boot) TESTML_COMPILER_DEBUG=$(debug) prove -v $(test)

test-pegex: node_modules ../pegex-js/npm
	rm -fr node_modules/pegex
	NODE_PATH=lib:../pegex-js/npm/lib prove -lv test/

update-grammar: node_modules ../pegex
	( \
	set -o pipefail; \
	grep -B99 make_tree lib/testml-compiler/grammar.coffee; \
	TESTML_COMPILER_GRAMMAR_PRINT=1 \
            ./bin/testml-compiler Makefile \
            | sed 's/^/    /' \
	) > tmp-grammar
	mv tmp-grammar lib/testml-compiler/grammar.coffee

../pegex:
	(cd ..; make pegex)

clean: ingy-npm-clean
	rm -fr node_modules
	rm -f tmp-grammar
	rm -fr test/.testml
