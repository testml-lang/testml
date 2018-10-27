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

export PATH := $(PWD)/bin:$(PWD)/src/testml-compiler-perl5/bin:$(PATH)

# All the current support languages:
ifeq ($(shell which perl),)
    $(error perl(5) is a minimum requirement for TestML development)
endif
ifneq ($(shell which bash),)
    LANG_ALL += bash
endif
ifneq ($(shell which node),)
    LANG_ALL += coffee
endif
ifneq ($(shell which go),)
    LANG_ALL += go
endif
ifneq ($(shell which node),)
    LANG_ALL += node
endif
LANG_ALL += perl5
ifneq ($(shell which perl6),)
    LANG_ALL += perl6
endif
ifneq ($(shell which python2),)
    LANG_ALL += python2
    found_python := ok
endif
ifneq ($(shell which python3),)
    LANG_ALL += python3
    found_python := ok
endif
ifeq ($(found_python),)
    ifneq ($(shell which python),)
	LANG_ALL += python
    endif
endif


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

# Directory to put the node_modules worktree:
NODE_MODULES := src/node_modules

EXT_ALL := \
    ext/cpp \
    ext/go \
    ext/perl5 \
    ext/perl6 \

# All the branches for `make work` which checks them out as worktree subdirs:
WORK := \
    compiler/coffee \
    eg/rotn \
    $(EXT_ALL) \
    $(NODE_MODULES) \
    note \
    $(RUN_ALL) \
    $(RUN_NEW) \
    site \
    talk/2018-lapm \
    talk/2018-openwest \
    talk/2018-tpc \
    talk/2018-tpceu \
    testml/compiler-tml \
    testml/cli-tml \
    testml/runtime-tml \

ALL_WORK := orphan $(WORK)
ALL_WORK := $(filter-out $(NODE_MODULES),$(ALL_WORK))

# All the branches for `make status`:
STATUS := $(ALL_WORK)

figlet := figlet -w 200
ifeq ($(shell type figlet 2>/dev/null || true),)
    figlet := echo
endif
P := %
C := $(shell tput cols)
line := printf "$P$Cs\n" | tr " " "-"
define header
	@$(line) && \
	$(figlet) "$(1)" && \
	$(line)
endef

#------------------------------------------------------------------------------
default: status

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
test-runtime-python2 test-runtime-python3: src/python
	$(call header,$@)
	TESTML_LANG_BIN=$(@:test-runtime-%=%) make -C $< test j=$(j)

# Run a specific language runtime test:
test-runtime-%: src/% ext/% ext/perl5
	$(call header,$@)
	make -C $< test j=$(j)

test-compiler: test-compiler-perl5 test-compiler-coffee

# Run all the compiler tests:    note:(`make -C` doesn't work here)
test-compiler-perl5: src/testml-compiler-perl5
	$(call header,$@)
	cd $<; make test j=$(j)

test-compiler-coffee: src/testml-compiler-coffee
ifneq ($(shell which node),)
	$(call header,$@)
	cd $<; make test j=$(j)
endif

# Test the output of various testml CLI invocations:
test-cli: ext/perl5
	$(call header,$@)
	PERL5LIB=ext/perl5 test=$(test) prove -v -j$(j) $${test:-test/cli-tml/*.tml}

# A special rule to run tests on travis-ci:
test-travis: test

test-docker:
	docker build --tag=testml-test-docker test/docker
	docker run --tty --rm --volume "$(PWD):/test" testml-test-docker bash -c 'cd /test && make test'

test-docker-command:
	@echo 'docker run --tty --rm --volume "$$PWD:/test" testml-test-docker bash -c "cd /test && make test"'

#------------------------------------------------------------------------------
# TestML repository managment rules:
#------------------------------------------------------------------------------

ext: $(EXT_ALL)

ext/bash ext/coffee ext/node ext/python:
	@# Nothing to do for $@

# The `make work` command:
work: $(WORK)

# worktree add a branch into a subdir:
$(ALL_WORK):
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $@ $@

$(NODE_MODULES):
	git branch --track node_modules origin/node_modules 2>/dev/null || true
	git worktree add -f $@ node_modules

# Rules to clean up the repo:
clean:
	find . -type d | grep -E '(\.testml|\.precomp|__pycache__)$$' | xargs rm -fr
	find . -type f | grep -E '\.(pyc|swp|swo)$$' | xargs rm -f

realclean: clean
	rm -fr $(ALL_WORK)
	git worktree prune
	rm -fr compiler eg ext runtime talk testml
	rm -fr $(NODE_MODULES)
	make -C src/coffee $@
	make -C src/go $@
	make -C src/node $@
	make -C src/perl5 $@
	make -C src/perl6 $@
	make -C src/python $@
	make -C src/testml-compiler-coffee $@
	make -C src/testml-compiler-perl5 $@

.PHONY: test

#------------------------------------------------------------------------------
# Import `make status` support:
include .makefile/status.mk
