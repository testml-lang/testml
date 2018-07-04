include ../../.makefile/test-tap.mk

default: help

test: test-tap

clean::
	find . | grep '\.precomp' | xargs rm -fr
