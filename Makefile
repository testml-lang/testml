MODULES := \
    babel-core \
    babel-preset-env \
    babel-preset-minify \
    codemirror \
    coffeescript \
    diff \
    docco \
    highlight.js \
    ingy-prelude \
    jison \
    lodash \
    markdown-it \
    pegex \
    underscore \
    webpack \
    ingy-npm-0.0.1.tgz \

update:
	rm -fr [a-z]* .bin
	mkdir node_modules
	npm pack ../../ingy-npm/
	npm install $(MODULES)
	rm -f package*
	[ $${PWD##*/} == node_modules ] || mv node_modules/* node_modules/.bin ./
	rmdir node_modules
	rm -f ingy-npm-0.0.1.tgz
	git add -A .
