define HELP
Try these make commands:

    make work           - Check out all branches into worktree layout
    make status         - Show status of all worktree subdirs
    make                - Same as `make status`
    make test           - Run all tests
    make test-perl5     - Run language specific tests
    make test-compiler  - Compiler tests
    make test-output    - Run CLI output tests
    make clean          - Remove generated files
    make realclean      - Even remove worktree subdirs
    make help           - Print this help

endef
export HELP

export PATH := $(PWD)/bin:$(PWD)/compiler/coffee/bin:$(PATH)

# All the current support languages:
LANG_ALL := \
    coffee \
    node \
    perl5 \
    perl6 \
    python \

# All the language test rules (like `test-perl5`):
TEST_ALL := $(LANG_ALL:%=test-run-%)

# All the language specific runtime code branhes (like `run/perl5`):
RUN_ALL := $(LANG_ALL:%=run/%)

# All the language module packaging branches (like `pkg/perl5` for CPAN):
PKG_ALL := pkg-node

# All the branches for `make work` which checks them out as worktree subdirs:
WORK := \
    compiler/coffee \
    eg/rotn \
    note \
    $(PKG_ALL) \
    $(RUN_ALL) \
    run/cpp \
    site \
    talk \

# All the branches for `make status`:
STATUS := \
    orphan \
    $(WORK) \
    test/compiler-tml \
    test/run-tml \

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
test: test-run test-compiler test-output

# Run all the language specific runtime tests:
test-run: $(TEST_ALL)

# Run a specific language runtime test:
test-run-%: run/%
	make -C $< test j=$(j)

# Run all the compiler tests:    note:(`make -C` doesn't work here)
test-compiler: compiler/coffee
	cd $<; make test j=$(j)

# Test the output of various testml CLI invocations:
test-output: run/perl5 compiler/coffee
	test=$(test) prove -v -j$(j) $${test:-test/output/*.tml}

# A special rule to run tests on travis-ci:
test-travis: test

#------------------------------------------------------------------------------
# TestML repository managment rules:
#------------------------------------------------------------------------------

# The `make work` command:
work: $(WORK) test/compiler-tml test/run-tml

# worktree add a branch into a subdir:
$(WORK) orphan:
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $(subst -,/,$@) $@

# worktree add rules for test branches (slightly different than above rule):
test/compiler-tml:
	git branch --track compiler-tml origin/compiler-tml 2>/dev/null || true
	git worktree add -f $@ compiler-tml

test/run-tml:
	git branch --track run-tml origin/run-tml 2>/dev/null || true
	git worktree add -f $@ run-tml

# Rules to clean up the repo:
clean:
	find . -type d | grep '\.testml$$' | xargs rm -fr
	find . -type d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.pyc' | xargs rm -f
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f
	rm -f package*

realclean: clean
	rm -fr $(WORK) orphan test/compiler-tml test/run-tml
	git worktree prune
	rm -fr compiler eg pkg run

.PHONY: test
