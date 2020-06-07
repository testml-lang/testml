export ROOT := ../..
export TESTML_COMPILER_TEST := $(ROOT)/test/compiler-tml

EXT := $(ROOT)/ext

export PATH := $(ROOT)/bin:$(TESTML_COMPILER_TEST)/bin:$(PATH)
export PERL5LIB := $(EXT)/perl
export TAG_PREFIX := compiler-perl

export TESTML_COMPILER_BOOTSTRAP := $(boot)
export TESTML_COMPILER_DEBUG := $(debug)

j = 1
test = test/*.tml

#------------------------------------------------------------------------------
default:

.PHONY: test
test: $(EXT)
	prove -v -j$(j) $(test)

update: update-grammar

update-grammar:
	( \
	    perl -Ilib -I../../ext/perl -MTestML::Compiler::Grammar=compile; \
	    perl -pi -e 's/\(\?=(?==|\\~)/(=/' lib/TestML/Compiler/Grammar.pm; \
	)

clean::
	rm -fr remove testml-compiler-*
	rm -f tmp-grammar
	rm -fr test/testml/.testml

realclean:: clean

#------------------------------------------------------------------------------
$(EXT):
	$(MAKE) -C $(ROOT) ext

#------------------------------------------------------------------------------
include pkg/package.mk

SHELL = bash
