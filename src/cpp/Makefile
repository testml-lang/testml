RUNTIME_LANG := cpp
ROOT := ../..

#------------------------------------------------------------------------------
default: help

test: ext/nlohmann/json.hpp test-tap

ext/nlohmann/json.hpp:
	mkdir -p ext/nlohmann
	curl -s https://raw.githubusercontent.com/nlohmann/json/develop/single_include/nlohmann/json.hpp > $@

clean::
	rm -fr ext

#------------------------------------------------------------------------------
include ../../.makefile/runtime.mk
