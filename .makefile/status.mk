status:
	@for d in $(STATUS); do \
	    [ -d $$d ] || continue; \
	    ( \
	      echo "=== $$d"; \
	      cd $$d; \
	      output=$$( \
		git status | grep -Ev '(^On branch|up.to.date|nothing to commit)'; \
		git log --graph --decorate --pretty=oneline --abbrev-commit -10 | grep wip; \
	      ); \
	      [ -z "$$output" ] || echo "$$output"; \
	    ); \
	done
	@echo "=== $$(git rev-parse --abbrev-ref HEAD)"
	@git status | grep -Ev '(^On branch|up.to.date|nothing to commit)' || true
	@git log --graph --decorate --pretty=oneline --abbrev-commit -10 | grep wip || true

