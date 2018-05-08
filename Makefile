lang := perl
test := test/*.tml

.PHONY: test
test:
	(. .rc; TESTML_LANG=perl prove -v $(test))
	./bin/testml -l perl $(test)
	./bin/testml-perl $(test)
	(. .rc; TESTML_LANG=perl6 prove -v $(test))
	./bin/testml -l perl6 $(test)
	./bin/testml-perl6 $(test)

clean:
	rm -fr test/.testml
	rm -fr lib/perl6/.precomp
