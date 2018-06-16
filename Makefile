update:
	rm -fr [a-z]* .bin
	mkdir node_modules
	npm install coffeescript diff ingy-prelude lodash
	rm -f package*
	mv node_modules/* node_modules/.bin .
	rmdir node_modules
	git add -A .
