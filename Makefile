test: lib/rotn.js
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
