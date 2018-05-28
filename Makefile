SITE := ../gh-pages

build: index.js

.PHONY: test
test: build testml compiler
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

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
	(cd $< && make npm)

../compiler/npm: ../compiler
	(cd $< && make npm)

../node ../compiler:
	(cd .. && make js-files $(@:../%=%))

update: yaml-test-suite ../compiler
	bin/make-yaml
	bin/make-test
	bin/make-ctest

yaml-test-suite:
	git clone -b fix-json --depth=1 git@github.com:yaml/$@

clean:
	rm -fr yaml-test-suite
	rm -f testml compiler
