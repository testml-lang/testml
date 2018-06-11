export TESTML_ROOT := $(PWD)
export PATH := $(TESTML_ROOT)/bin:$(PATH)

TAP_RUN := coffee node perl perl6 python
TAP_TESTS := $(TAP_RUN:%=test-%-tap)
UNIT_RUN := python
UNIT_TESTS := $(UNIT_RUN:%=test-%-unit)

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
    rotn \
    site \
    talk \

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
test: test-tap test-unit

test-travis: test-tap test-output
	# XXX test-unit is failing on travis at the moment

test-tap: $(TAP_TESTS)

test-unit: $(UNIT_TESTS)

test-all: test test-output

test-coffee-tap test-node-tap: testml-tml node_modules js-files
ifdef test
	TESTML_RUN=$(@:test-%=%) prove -v $(test)
else
	TESTML_RUN=$(@:test-%=%) prove -v test/$(subst -tap,,$(subst test-,,$@))/testml/*.tml
endif

test-perl-tap test-perl6-tap test-python-tap: testml-tml
ifdef test
	TESTML_RUN=$(@:test-%=%) prove -v $(test)
else
	TESTML_RUN=$(@:test-%=%) prove -v test/$(subst -tap,,$(subst test-,,$@))/testml/*.tml
endif

test-python-unit: testml-tml
ifdef test
	testml-python-unit $(test)
else
	testml-python-unit \
	  test/python/testml/0{6,7,9}0*.tml \
	  test/python/testml/1*.tml
endif


test-output:
ifdef test
	prove -v $(test)
else
	prove -v test/output/testml/*.tml
endif

node_modules: ../testml-node-modules
	cp -r $< $@

../testml-node-modules:
	mkdir node_modules
	npm install --save-dev diff ingy-prelude lodash
	rm -f package*
	mv node_modules $@

work: $(WORKTREES)

$(WORKTREES) orphan-template:
	git branch --track $@ origin/$@ 2>/dev/null || true
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
	rm -fr node_modules/
	rm -f package*
	find . -type d | grep '\.testml$$' | xargs rm -fr
	find . -type d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f
	find . -name '*.pyc' | xargs rm -f

realclean: clean
	rm -fr $(WORKTREES) orphan-template
	git worktree prune
