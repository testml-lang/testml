.PHONY: test
test:
	(sleep 0.5; open http://localhost:1234/) &
	static -p 1234

publish:
	git add -A .
	git commit -m "$$(date)"
	git push -f
