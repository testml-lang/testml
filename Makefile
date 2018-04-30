ifneq ($(wildcard ../ingy-npm),)
    include ../ingy-npm/share/ingy-npm.mk
else
    $(warning Error: ../ingy-npm does not exist)
    $(warning Try: git clone git@github.com:ingydotnet/ingy-npm ../ingy-npm)
    $(error Fix your errors)
endif

test: node_modules
	(source .rc; prove -lv test/)

clean: ingy-npm-clean
	rm -fr node_modules
