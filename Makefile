default:

update: clean
	git clone git@github.com:moritz/json json-tiny
	mv json-tiny/lib/* .
	rm -fr json-tiny

clean:
	rm -fr json-tiny

realclean: clean
	rm -fr JSON
