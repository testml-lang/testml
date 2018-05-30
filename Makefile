export TESTML_ROOT := $(PWD)
export PATH := $(TESTML_ROOT)/bin:$(PATH)

TAP_RUN := coffee node perl perl6 python
TAP_TESTS := $(TAP_RUN:%=test-%-tap)

COFFEE_FILES := $(shell find lib/coffee -type f | grep -v '\.swp$$') $(shell find test | grep -E '\.coffee$$' | grep -v '\.swp$$')
JS_FILES := $(COFFEE_FILES:lib/coffee/%.coffee=lib/node/%.js)
JS_FILES := $(JS_FILES:test/%.coffee=test/%.js)
JS_FILES := $(subst coffee,node,$(JS_FILES))

WORKTREES := \
    compiler \
    compiler-site \
    compiler-tml \
    gh-pages \
    node \
    pegex \
    playground \
    testml-tml \
    site \

export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)

status:
	@for d in $(WORKTREES); do \
	    [ -d $$d ] || continue; \
	    ( \
		echo "=== $$d"; \
		cd $$d; \
		git status | grep -Ev '(^On branch|up-to-date|nothing to commit)'; \
		git log --graph --decorate --pretty=oneline --abbrev-commit -10 | grep wip; \
		echo; \
	    ); \
	done
	@echo "=== master"
	@git status | grep -Ev '(^On branch|up-to-date|nothing to commit)' || true

.PHONY: test
test: test-tap

test-tap: $(TAP_TESTS)

test-all: test test-out

test-coffee-tap test-node-tap: testml-tml node_modules js-files
ifdef test
	TESTML_RUN=$(@:test-%=%) prove -v $(test)
else
	TESTML_RUN=$(@:test-%=%) prove -v test/testml/*.tml test/$(subst -tap,,$(subst test-,,$@))/testml/*.tml
endif

test-perl-tap test-perl6-tap test-python-tap: testml-tml
ifdef test
	TESTML_RUN=$(@:test-%=%) prove -v $(test)
else
	TESTML_RUN=$(@:test-%=%) prove -v test/testml/*.tml
endif

test-out:
	prove -v test/out/testml/*.tml

node_modules: ../testml-node-modules
	cp -r $< $@

../testml-node-modules:
	npm install --save-dev diff ingy-prelude lodash
	rm -f package*
	mv node_modules $@

work: $(WORKTREES)

$(WORKTREES) orphan-template:
	git worktree add -f $@ $@

playground-test: playground
	make -C $< test

npm: node js-files
	(cd $<; make clean npm)

js-files: $(JS_FILES)

lib/node/%.js: lib/coffee/%.coffee
	coffee -cp $< > $@

test/%.js: test/%.coffee
	coffee -cp $< > $@

test/node/%.js: test/coffee/%.coffee
	coffee -cp $< > $@

clean:
	rm -fr lib/perl6/.precomp/
	rm -fr node_modules/
	rm -f package*
	find . -d | grep '\.testml$$' | xargs rm -fr
	find . -d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.pyc' | xargs rm

realclean: clean
	rm -fr $(WORKTREES) orphan-template
	git worktree prune
