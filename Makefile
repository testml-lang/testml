.PHONY: test
test: testml testml-compiler index.js
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

testml: ../node/npm
	ln -s $< $@

testml-compiler: ../../testml-compiler/npm
	ln -s $< $@

index.js: index.coffee
	coffee -cp $< > $@

../node/npm:
	(cd ..; make npm)

../../testml-compiler/npm:
	(cd ../../testml-compiler; make npm)

update: yaml-test-suite
	bin/make-yaml
	bin/make-test
	bin/make-ctest

yaml-test-suite:
	git clone -b fix-json --depth=1 git@github.com:yaml/$@

push:
	git add -A .
	git commit -m "$$(date)"
	git push -f

clean:
	rm -fr yaml-test-suite
	rm -f testml testml-compiler
