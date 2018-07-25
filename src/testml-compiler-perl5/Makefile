export ROOT := ../..
export TESTML_COMPILER_TEST := $(ROOT)/test/compiler-tml

EXT := $(ROOT)/ext

export PATH := $(ROOT)/bin:$(TESTML_COMPILER_TEST)/bin:$(PATH)
export PERL5LIB := $(EXT)/perl5
export TAG_PREFIX := compiler-perl5

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
	@echo "update-grammar not yet ported"
	@exit 123
	# ( \
	# set -o pipefail; \
	# grep -B99 make_tree lib/testml-compiler/grammar.coffee; \
	# TESTML_COMPILER_GRAMMAR_PRINT=1 \
	#     ./bin/testml-compiler Makefile \
	#     | sed 's/^/    /' \
	# ) > tmp-grammar
	# mv tmp-grammar lib/testml-compiler/grammar.coffee

clean::
	rm -fr remove testml-compiler-*
	rm -f tmp-grammar
	rm -fr test/testml/.testml

realclean:: clean

#------------------------------------------------------------------------------
$(EXT):
	make -C $(ROOT) ext

#------------------------------------------------------------------------------
include pkg/package.mk
