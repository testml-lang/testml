ifneq ($(wildcard ../ingy-npm),)
    include ../ingy-npm/share/ingy-npm.mk
else
    $(warning Error: ../ingy-npm does not exist)
    $(warning Try: git clone git@github.com:ingydotnet/ingy-npm ../ingy-npm)
    $(error Fix your errors)
endif

test = test/
debug =

test: node_modules
	(source .rc; NODE_PATH=lib DEBUG=$(debug) prove -v $(test))

test-pegex: node_modules ../pegex-js/npm
	rm -fr node_modules/pegex
	(source .rc; NODE_PATH=lib:../pegex-js/npm/lib prove -lv test/)

clean: ingy-npm-clean
	rm -fr node_modules
