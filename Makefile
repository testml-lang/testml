SITE := ../gh-pages

build: coffeescript node_modules
	cake doc:site

.PHONY: test
test: build
	(sleep 0.5; open http://localhost:1234/) &
	(cd docs && static -p 1234)

site: $(SITE) build
	cp -r docs/* $<
	rm -f $</v2/*.html

coffeescript:
	git clone --depth=1 http://github.com/jashkenas/$@

node_modules: ../../testml-site-node-modules
	cp -r $< $@

../../testml-site-node-modules:
	npm install .
	rm -f package-lock.json
	mv node_modules $@

$(SITE):
	(cd .. && make gh-pages)

clean:
	rm -fr coffeescript
	rm -fr node_modules
	rm -f package-lock.json
	rm -f docs/v2/index.html
