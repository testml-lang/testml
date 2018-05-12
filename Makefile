TAP_RUNNERS := perl-tap perl6-tap
TAP_TESTS := $(TAP_RUNNERS:%=test-%)

test := test/*.tml

.PHONY: test
test: $(TAP_TESTS)

test-all: $(TAP_TESTS)
	./test/test-cli.sh

$(TAP_TESTS):
	(. .rc; TESTML_RUN=$(@:test-%=%) prove -v $(test))

node:
	git worktree add -f $@ $@

clean:
	rm -fr test/.testml/
	rm -fr lib/perl6/.precomp/
	rm -fr node/
	git worktree prune
