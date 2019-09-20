SHELL = bash

OPEN := $(shell command -v xdg-open)
OPEN ?= open

.PHONY: test
test:
	(sleep 0.5; $(OPEN) http://localhost:1234/ &>/dev/null) &
	static -p 1234

commit:
	git add -A .
	git commit -m "$$(date)"

publish: commit
	git push -f
