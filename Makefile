.PHONY: test
test:
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

commit:
	git add -A .
	git commit -m "$$(date)"

publish: commit
	git push -f
