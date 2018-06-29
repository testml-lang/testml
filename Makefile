export TESTML_ROOT := $(PWD)
export TESTML_COMPILER_ROOT := $(PWD)/compiler/coffee
export PATH := $(TESTML_ROOT)/bin:$(TESTML_COMPILER_ROOT)/bin:$(PATH)

LANG_ALL := coffee node perl5 perl6 python
TEST_ALL := $(LANG_ALL:%=test-%)
RUN_ALL := $(LANG_ALL:%=run/%)
PKG_ALL := pkg-node

WORK := \
    compiler/coffee \
    eg/rotn \
    note \
    $(PKG_ALL) \
    $(RUN_ALL) \
    site \
    talk \

STATUS := $(WORK) \
    test/compiler-tml \
    test/run-tml \

export TESTML_DEVEL := $(devel)
export TESTML_COMPILER_DEBUG := $(debug)
j = 1

include .makefile/status.mk

test: test-run test-compiler test-output

test-run: $(TEST_ALL)

test-%: run/%
	make -C $< test

test-compiler: compiler/coffee
	cd $< && make test

test-travis: test

test-output: run/perl5 compiler/coffee
	test=$(test) prove -v -j$(j) $${test:-test/output/*.tml}

work: $(WORK)

$(WORK) orphan:
	git branch --track $@ origin/$@ 2>/dev/null || true
	git worktree add -f $(subst -,/,$@) $@

test/compiler-tml:
	git branch --track compiler-tml origin/compiler-tml 2>/dev/null || true
	git worktree add -f $@ compiler-tml

test/run-tml:
	git branch --track run-tml origin/run-tml 2>/dev/null || true
	git worktree add -f $@ run-tml

clean:
	rm -f package*
	find . -type d | grep '\.testml$$' | xargs rm -fr
	find . -type d | grep '\.precomp$$' | xargs rm -fr
	find . -name '*.swp' | xargs rm -f
	find . -name '*.swo' | xargs rm -f

realclean: clean
	rm -fr $(WORK) test/compiler-tml test/run-tml
	git worktree prune
	rm -fr compiler eg pkg run

.PHONY: test
