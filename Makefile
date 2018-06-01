help:
	@echo 'make renumber 	- Renumber all test file'

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
