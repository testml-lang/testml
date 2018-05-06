lang := perl
test := test/*.tml

.PHONY: test
test:
	(. .rc; TESTML_LANG=$(lang) prove -v $(test))

clean:
	rm -fr test/.testml
