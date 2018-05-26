SITE := ../gh-pages

.PHONY: test
test: build
	(sleep 0.5; open http://localhost:1234/) &
	(cd $(SITE) && static -p 1234)

publish: build
	make -C $(SITE) publish

build: $(SITE) coffeescript node_modules
	cake doc:site
	cp -r docs/* $(SITE)

coffeescript:
	git clone --depth=1 http://github.com/jashkenas/$@

node_modules:
	npm install .
	rm -f package-lock.json

$(SITE):
	git worktree add -f $@ gh-pages

clean:
	rm -fr coffeescript
	rm -fr node_modules
	rm -f package-lock.json
	rm -f docs/v2/index.html
