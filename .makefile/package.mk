check::
	@[ -z "`git status -s`" ] || { \
	    echo "Can't publish. Uncommited git changes"; \
	    exit 1 ; \
	}

