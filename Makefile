define HELP
  Try these make commands:

    make                    - Same as `make status`
    make test               - Run all tests
    make test-runtime-perl5 - Run language specific tests
    make test-compiler      - Compiler tests
    make test-cli           - Run CLI output tests
    make clean              - Remove generated files
    make realclean          - Even remove worktree subdirs
    make work               - Check out all branches into worktree layout
    make status             - Show status of all worktree subdirs
    make help               - Print this help

endef
export HELP

export PATH := $(PWD)/bin:$(PWD)/src/testml-compiler-coffee/bin:$(PATH)

# All the current support languages:
LANG_ALL := \
    coffee \
    node \
    perl5 \
    perl6 \
    python \

# New language runtimes in progress:
LANG_NEW := \
    cpp \
    gambas \

# All the language test rules (like `test-runtime-perl5`):
TEST_ALL := $(LANG_ALL:%=test-runtime-%)

# All the language specific runtime code branches (like `run/perl5`):
RUNTIME_ALL := $(LANG_ALL:%=runtime/%)

# New language specific runtime branches in progress:
RUNTIME_NEW := $(LANG_NEW:%=runtime/%)

# All the branches for `make work` which checks them out as worktree subdirs:
WORK := \
    compiler/coffee \
    eg/rotn \
    note \
    $(RUN_ALL) \
    $(RUN_NEW) \
    site \
    talk/2018-openwest \
    talk/2018-tpc \
    testml/compiler-tml \
    testml/cli-tml \
    testml/runtime-tml \

ALL_WORK := orphan $(WORK)

# All the branches for `make status`:
STATUS := $(ALL_WORK)

# Import `make status` support:
include .makefile/status.mk

help:
	@echo "$$HELP"

#------------------------------------------------------------------------------
# Testing rules:
#------------------------------------------------------------------------------
# TAP prove parallel testing flag:
j = 1

# Run all tests for TestML:
test: test-runtime test-compiler test-cli

# Run all the language specific runtime tests:
test-runtime: $(TEST_ALL)

# Run a specific language runtime test:
test-runtime-%: src/%
	make -C $< test j=$(j)

# Run all the compiler tests:    note:(`make -C` doesn't work here)
test-compiler: src/testml-compiler-coffee
	cd $<; make test j=$(j)

# Test the output of various testml CLI invocations:
test-cli:
	test=$(test) prove -v -j$(j) $${test:-test/cli-tml/*.tml}

# A special rule to run tests on travis-ci:
test-travis: test

compiler::
ifeq ($(shell which testml-compiler),)
	cd src/testml-compiler-coffee && make node_modules
endif

#------------------------------------------------------------------------------
# TestML repository managment rules:
#------------------------------------------------------------------------------

# The `make work` command:
work: $(WORK)

# worktree add a branch into a subdir:
$(ALL_WORK):
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@

# Rules to clean up the repo:
clean:
	find . -type d | grep '\.testml$$' | xargs rm -fr
	find . -type d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.pyc' | xargs rm -f
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f

realclean: clean
	rm -fr $(ALL_WORK)
	git worktree prune
	rm -fr compiler eg runtime src/node_modules talk testml
	make -C src/node $@

.PHONY: test
