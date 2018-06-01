help:
	@echo 'make renumber 	- Renumber all test files'
	@echo 'make clean    	- Remove all generated files'

renumber:
	@( \
	    i=1; \
	    for tml in *.tml; do \
		new="$$(printf "%02d0" "$$i")-$${tml#*-}"; \
		[ $$tml == $$new ] || \
		    (set -x; git mv "$$tml" "$$new"); \
		: $$((i++)); \
	    done \
	)

clean:
	find . -type d | grep '\.testml' | xargs rm -fr
