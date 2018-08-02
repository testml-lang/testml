ROOT := ../..

export PATH := $(ROOT)/bin:$(PATH)
export TESTML_ROOT := $(shell cd $(ROOT); pwd)

NODE_MODULES := $(TESTML_ROOT)/src/node_modules
EXT := $(TESTML_ROOT)/ext
JS := $(TESTML_ROOT)/src/node/lib

export NODE_PATH := lib:test
export PYTHONPATH := lib:test
export PERL5LIB := $(TESTML_ROOT)/ext/perl5:lib:test
export PERL6LIB := $(TESTML_ROOT)/ext/perl6,lib,test

LANG := coffee node perl5 perl6 python
TESTS := $(LANG:%=test-%-tap)

test: $(TESTS)

tests: $(TESTS)

$(TESTS): lib/rotn.js test/testml-bridge.js $(EXT) $(NODE_MODULES) $(JS)
ifdef test
	TESTML_RUN=$(@:test-%=%) prove -v $(test)
else
	TESTML_RUN=$(@:test-%=%) prove -v test/*.tml
endif

%.js: %.coffee
	coffee -cp $< > $@

pie-test: lib/rotn.js
	NODE_PATH=lib coffee -e 'require "rotn"; rotn = new RotN "I like pie."; console.log rotn.rot(13).rot(13).string'
	NODE_PATH=lib node -e 'require("rotn"); rotn = new RotN("I like pie."); console.log(rotn.rot(13).rot(13).string)'
	PERL5LIB=lib perl -E 'use RotN; my $$rotn = RotN->new("I like pie."); say $$rotn->rot(13)->rot(13)->{string}'
	PERL6LIB=lib perl6 -e 'use RotN; my $$rotn = RotN.new("I like pie."); say $$rotn.rot(13).rot(13).string'
	PYTHONPATH=lib python -c 'import rotn; myrotn = rotn.RotN("I like pie."); print myrotn.rot(13).rot(13).string'

%.js: %.coffee
	coffee -cbp $< | tail -n+2 > $@

$(EXT):
	make -C $(TESTML_ROOT) ext >/dev/null

$(NODE_MODULES):
	make -C $(TESTML_ROOT) src/node_modules >/dev/null

$(JS):
	make -C $(TESTML_ROOT)/src/node js-files

clean:
	rm -fr node_modules/
	rm -f package*
	find . -type d | grep '\.testml$$' | xargs rm -fr
	find . -type d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.pyc' | xargs rm -f
