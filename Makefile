# Maybe use something based on `git rev-parse --git-dir`
export ROOT := ../..
SITE := ../gh-pages

#------------------------------------------------------------------------------
default:

.PHONY: test
test: build compiler testml
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

site: $(SITE) build update
	(cd $(SITE)/playground/ && rm -fr index* yaml test ctest)
	cp -r index* yaml test ctest $(SITE)/playground/

build: index.js

update: yaml-test-suite
	bin/make-yaml
	bin/make-test
	bin/make-ctest

publish: build update
	git add -A .
	git commit -m 'Update tests' || true
	git push || true

clean:
	rm -f compiler testml
	rm -fr yaml-test-suite

clean-test:
	rm -fr $(ROOT)/src/node/build
	rm -fr $(ROOT)/src/testml-compiler-coffee/build

test-clean: clean-test test

#------------------------------------------------------------------------------
$(SITE):
	(cd .. && make gh-pages)

index.js: index.coffee
	coffee -cp $< > $@

testml: $(ROOT)/src/node/build
	ln -s $< $@

compiler: $(ROOT)/src/testml-compiler-coffee/build
	ln -s $< $@

$(ROOT)/src/node/build: $(ROOT)/src/node
	(cd $< && make build)

$(ROOT)/src/testml-compiler-coffee/build: $(ROOT)/src/testml-compiler-coffee
	(cd $< && make build)

yaml-test-suite:
	git clone --branch=master --depth=1 git@github.com:yaml/$@
