# Maybe use something based on `git rev-parse --git-dir`
TOP := ../..
SITE := ../gh-pages

export TOP := $(TOP)

build: index.js

update: yaml-test-suite $(TOP)/compiler-tml $(TOP)/testml-tml
	bin/make-yaml
	bin/make-test
	bin/make-ctest

publish: build update
	git add -A .
	git commit -m 'Update tests' || true
	git push || true

.PHONY: test
test: build testml compiler
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

test-clean: clean-test test

site: $(SITE) build update
	(cd $(SITE)/playground/ && rm -fr index* yaml test ctest)
	cp -r index* yaml test ctest $(SITE)/playground/

$(SITE):
	(cd .. && make gh-pages)

testml: $(TOP)/node/npm
	ln -s $< $@

compiler: $(TOP)/compiler/npm
	ln -s $< $@

index.js: index.coffee
	coffee -cp $< > $@

$(TOP)/node/npm: $(TOP)/node
	(cd $(TOP) && make js-files)
	(cd $< && make npm)

$(TOP)/compiler/npm: $(TOP)/compiler
	(cd $< && make npm)

$(TOP)/node $(TOP)/compiler $(TOP)/compiler-tml $(TOP)/testml-tml:
	(cd $(TOP) && make $(@:$(TOP)/%=%))

yaml-test-suite:
	git clone -b master --depth=1 git@github.com:yaml/$@

clean:
	rm -fr yaml-test-suite
	rm -f testml compiler

clean-test:
	rm -fr $(TOP)/node/npm
	rm -fr $(TOP)/compiler/npm
