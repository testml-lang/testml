export PATH := ../bin:$(PATH)
export TESTML_ROOT := $(PWD)/..

export NODE_PATH := lib:test
export PYTHONPATH := lib:test
export PERL5LIB := lib:test
export PERL6LIB := lib,test

LANG := coffee node perl perl6 python
TESTS := $(LANG:%=test-%-tap)

test: $(TESTS)

tests: $(TESTS)

$(TESTS): lib/rotn.js test/testml-bridge.js
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

clean:
	rm -fr node_modules/
	rm -f package*
	find . -type d | grep '\.testml$$' | xargs rm -fr
	find . -type d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.pyc' | xargs rm -f
