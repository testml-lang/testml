# Maybe use something based on `git rev-parse --git-dir`
TOP := ../..
SITE := ../gh-pages

export TOP := $(TOP)

build: index.js

update: compiler-tml run-tml yaml-test-suite $(TOP)/run/coffee
	bin/make-yaml
	bin/make-test
	bin/make-ctest

publish: build update
	git add -A .
	git commit -m 'Update tests' || true
	git push || true

.PHONY: test
test: build testml-js compiler-js
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

test-clean: clean-test test

site: $(SITE) build update
	(cd $(SITE)/playground/ && rm -fr index* yaml test ctest)
	cp -r index* yaml test ctest $(SITE)/playground/

$(SITE):
	(cd .. && make gh-pages)

compiler-tml run-tml:
	git branch --track test/$@ origin/test/$@ 2>/dev/null || true
	git worktree add -f $@ test/$@

testml-js: $(TOP)/run/node/npm

compiler-js: $(TOP)/compiler/coffee/npm

index.js: index.coffee
	coffee -cp $< > $@

$(TOP)/run/node/npm: $(TOP)/run/node
	(cd $(TOP) && make js-files)
	(cd $< && make npm)

$(TOP)/compiler/coffee/npm: $(TOP)/compiler/coffee
	(cd $< && make npm)

$(TOP)/run/node $(TOP)/run/coffee $(TOP)/compiler/coffee:
	(cd $(TOP) && make $(@:$(TOP)/%=%))

yaml-test-suite:
	git clone -b master --depth=1 git@github.com:yaml/$@

clean:
	rm -fr yaml-test-suite
	rm -fr run-tml compiler-tml

clean-test:
	rm -fr $(TOP)/run/node/npm
	rm -fr $(TOP)/compiler/coffee/npm
