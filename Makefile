runtime := perl

.PHONY: test
test:
	(. .rc; TESTML_RUNTIME=$(runtime) prove -v test/*.tml)

clean:
	rm -fr test/.testml
