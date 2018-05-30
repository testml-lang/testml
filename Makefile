SITE := ../gh-pages

build: index.js

.PHONY: test
test: build testml compiler
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

test-clean: clean-test test

site: $(SITE)
	cp -r index* yaml test ctest $(SITE)/playground/

$(SITE):
	(cd .. && make gh-pages)

testml: ../node/npm
	ln -s $< $@

compiler: ../compiler/npm
	ln -s $< $@

index.js: index.coffee
	coffee -cp $< > $@

../node/npm: ../node
	(cd .. && make js-files)
	(cd $< && make npm)

../compiler/npm: ../compiler
	(cd $< && make npm)

../node ../compiler ../compiler-tml ../testml-tml:
	(cd .. && make $(@:../%=%))

update: yaml-test-suite ../compiler-tml ../testml-tml
	bin/make-yaml
	bin/make-test
	bin/make-ctest

yaml-test-suite:
	git clone -b master --depth=1 git@github.com:yaml/$@

clean:
	rm -fr yaml-test-suite
	rm -f testml compiler

clean-test:
	rm -fr ../node/npm
	rm -fr ../compiler/npm
