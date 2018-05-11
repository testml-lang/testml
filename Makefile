INGY_NPM := ../ingy-npm

ifneq ($(wildcard $(INGY_NPM)),)
    include $(INGY_NPM)/share/ingy-npm.mk
else
    $(warning Error: $(INGY_NPM) does not exist)
    $(warning Try: git clone git@github.com:ingydotnet/ingy-npm $(INGY_NPM))
    $(error Fix your errors)
endif

test = test/
debug =

test: node_modules
	(source .rc; NODE_PATH=lib TESTML_COMPILER_DEBUG=$(debug) \
          prove -v $(test))

test-pegex: node_modules ../pegex-js/npm
	rm -fr node_modules/pegex
	(source .rc; NODE_PATH=lib:../pegex-js/npm/lib prove -lv test/)

update-grammar: node_modules
	( \
	set -o pipefail; \
	grep -B99 make_tree lib/testml-compiler/grammar.coffee; \
	TESTML_COMPILER_GRAMMAR_PRINT=1 \
            ./bin/testml-compiler Makefile \
            | sed 's/^/    /' \
	) > tmp-grammar
	mv tmp-grammar lib/testml-compiler/grammar.coffee

clean: ingy-npm-clean
	rm -fr node_modules
	rm -f tmp-grammar
