define HELP
  Try these make commands:

    make                    - Same as `make status`
    make test               - Run all tests
    make test-runtime-perl  - Run language specific tests
    make test-compiler      - Compiler tests
    make test-cli           - Run CLI output tests
    make clean              - Remove generated files
    make realclean          - Even remove worktree subdirs
    make work               - Check out all branches into worktree layout
    make status             - Show status of all worktree subdirs
    make help               - Print this help

endef
export HELP

export PATH := $(PWD)/bin:$(PWD)/src/testml-compiler-perl/bin:$(PWD)/src/node_modules/.bin:$(PATH)

# All the current support languages:
ifeq ($(shell which bash 2>/dev/null),)
    $(error 'bash' is a minimum requirement for TestML development)
endif
ifeq ($(shell which perl 2>/dev/null),)
    $(error 'perl' is a minimum requirement for TestML development)
endif

LANG_ALL = bash
ifneq ($(shell which node 2>/dev/null),)
    export TESTML_HAS_LANG_COFFEE := 1
    LANG_ALL += coffee
endif
ifneq ($(shell which go 2>/dev/null),)
  ifeq ($(shell perl -e 'print "ok" if $$ARGV[0] =~ /go1\.1[01]/' '$(shell go version)'),ok)
    export TESTML_HAS_LANG_GO := 1
    LANG_ALL += go
  endif
endif
ifneq ($(shell which node 2>/dev/null),)
    export TESTML_HAS_LANG_NODE := 1
    LANG_ALL += node
endif

LANG_ALL += perl

ifneq ($(shell which python 2>/dev/null),)
    export TESTML_HAS_LANG_PYTHON := 1
    LANG_ALL += python
endif
ifneq ($(shell which python2 2>/dev/null),)
    export TESTML_HAS_LANG_PYTHON2 := 1
    LANG_ALL += python2
endif
ifneq ($(shell which python3 2>/dev/null),)
    export TESTML_HAS_LANG_PYTHON3 := 1
    LANG_ALL += python3
endif
ifneq ($(shell which raku 2>/dev/null),)
    export TESTML_HAS_LANG_RAKU
    LANG_ALL += raku
endif
ifneq ($(shell which ruby),)
    export TESTML_HAS_LANG_RUBY := 1
    LANG_ALL += ruby
endif


# New language runtimes in progress:
LANG_NEW := \
    cpp \
    gambas \

# All the language test rules (like `test-runtime-perl`):
TEST_ALL := $(LANG_ALL:%=test-runtime-%)

# Remove Go from TEST_ALL for now:
TEST_ALL := $(patsubst test-runtime-go,,$(TEST_ALL))

# All the language specific runtime code branches (like `run/perl`):
RUNTIME_ALL := $(LANG_ALL:%=runtime/%)

# New language specific runtime branches in progress:
RUNTIME_NEW := $(LANG_NEW:%=runtime/%)

# Directory to put the node_modules worktree:
NODE_MODULES := src/node_modules

EXT_ALL := \
    ext/cpp \
    ext/go \
    ext/perl \
    ext/raku \

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
    talk/2018-pdxpm \
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
ifeq ($(shell which figlet 2>/dev/null),)
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
testml-python test-runtime-python2 test-runtime-python3: src/python
	$(call header,$@)
	TESTML_LANG_BIN=$(@:test-runtime-%=%) $(MAKE) -C $< test j=$(j)

# Run a specific language runtime test:
test-runtime-%: src/% ext/% ext/perl
	$(call header,$@)
	$(MAKE) -C $< test j=$(j)

ifneq ($(TESTML_HAS_LANG_NODE),)
test-compiler: test-compiler-perl test-compiler-coffee
else
test-compiler: test-compiler-perl
endif

# Run all the compiler tests:    note:(`$(MAKE) -C` doesn't work here)
test-compiler-perl: src/testml-compiler-perl
	$(call header,$@)
	cd $<; $(MAKE) test j=$(j)

test-compiler-coffee: src/testml-compiler-coffee
	$(call header,$@)
	cd $<; $(MAKE) test j=$(j)

# Test the output of various testml CLI invocations:
ifneq ($(TESTML_HAS_LANG_NODE),)
test-cli: ext/perl ext/raku src/node/lib $(NODE_MODULES)
else
test-cli: ext/perl ext/raku
endif
	$(call header,$@)
	PERL5LIB=ext/perl test=$(test) prove -v -j$(j) $${test:-test/cli-tml/*.tml}

# A special rule to run tests on travis-ci:
test-travis: test

test-docker:
	docker build --tag=testml-test-docker test/docker
	docker run --tty --rm --volume "$(PWD):/test" testml-test-docker bash -c 'cd /test && $(MAKE) test'

test-docker-command:
	@echo 'docker run --tty --rm --volume "$$PWD:/test" testml-test-docker bash -c "cd /test && $(MAKE) test"'

shellcheck:
	shellcheck `grep -lEr '^#!.*sh' . | grep -Ev '(\.git|\.tml$$|lingy|node_modules)'`

#------------------------------------------------------------------------------
# TestML repository managment rules:
#------------------------------------------------------------------------------

ext: $(EXT_ALL)

ext/bash ext/coffee ext/node ext/python ext/ruby:
	@# Nothing to do for $@

src/node/lib: $(NODE_MODULES)
	$(MAKE) -C src/node js-files

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
	find . -type d | grep -E '(\.testml|\.precomp)$$' | xargs rm -fr
	find . -type f | grep -E '\.(swp|swo)$$' | xargs rm -f

realclean: clean
	rm -fr $(ALL_WORK)
	git worktree prune
	rm -fr compiler eg ext runtime talk testml
	rm -fr $(NODE_MODULES)
	$(MAKE) -C src/coffee $@
	$(MAKE) -C src/go $@
	$(MAKE) -C src/node $@
	$(MAKE) -C src/perl $@
	$(MAKE) -C src/python $@
	$(MAKE) -C src/raku $@
	$(MAKE) -C src/ruby $@
	$(MAKE) -C src/testml-compiler-coffee $@
	$(MAKE) -C src/testml-compiler-perl $@

.PHONY: test

#------------------------------------------------------------------------------
# Import `make status` support:
include .makefile/status.mk

SHELL = bash
