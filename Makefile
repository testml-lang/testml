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
    underscore \
    webpack \

update:
	rm -fr [a-z]* .bin
	mkdir node_modules
	npm install $(MODULES)
	rm -f package*
	[ $${PWD##*/} == node_modules ] || mv node_modules/* node_modules/.bin ./
	rmdir node_modules
	git add -A .
