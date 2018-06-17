WORK := \
    gh-pages \
    playground \

STATUS := $(WORK)

include ../.makefile/status.mk

publish: site
	make -C gh-pages publish
	make -C playground publish

site: gh-pages playground build
	cp -r docs/* $<
	rm -f $</v2/*.html
	make -C playground site

build: coffeescript ../node_modules
	cake doc:site

.PHONY: test
test: site
	(sleep 0.5; open http://localhost:1234/) &
	(cd gh-pages && static -p 1234)

coffeescript:
	git clone --depth=1 http://github.com/jashkenas/$@

$(WORK):
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@

../node_modules:
	make -C .. node_modules

clean:
	rm -f package-lock.json
	rm -f docs/v2/index.html

realclean: clean
	rm -fr $(WORK) coffeescript
