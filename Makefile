TAP_RUNNERS := coffee-tap perl-tap perl6-tap
TAP_TESTS := $(TAP_RUNNERS:%=test-%)

test := test/*.tml

.PHONY: test
test: node_modules $(TAP_TESTS)

test-all: test
	./test/test-cli.sh

$(TAP_TESTS):
	(. .rc; TESTML_RUN=$(@:test-%=%) prove -v $(test))

node_modules:
	npm install --save-dev lodash tap

node:
	git worktree add -f $@ $@

clean:
	rm -fr test/.testml/
	rm -fr lib/perl6/.precomp/
	rm -fr node/
	rm -fr node_modules/
	rm -f package*
	git worktree prune
