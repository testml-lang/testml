lang := perl
test := test/*.tml

.PHONY: test
test:
	(. .rc; TESTML_LANG=perl prove -v $(test))
	./bin/testml -l perl $(test)
	./bin/testml-perl $(test)

clean:
	rm -fr test/.testml
