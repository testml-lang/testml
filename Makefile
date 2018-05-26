default:

update: clean boost nlohmann

boost:
	git clone git@github.com:boostorg/callable_traits
	mv callable_traits/include/boost .
	rm -fr callable_traits

nlohmann:
	mkdir $@
	curl -s https://raw.githubusercontent.com/nlohmann/json/develop/single_include/nlohmann/json.hpp > $@/json.hpp

clean:
	rm -fr boost nlohmann
