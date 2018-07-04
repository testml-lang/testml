include ../../.makefile/test-tap.mk

default: help

test: test-tap test-unit

test-unit: $(TOP)/test/run-tml compiler
	testml-python-unit $(test)

clean::
	find . -name '*.pyc' | xargs rm -f
