MODULES := Capture::Tiny Pegex Text::Diff Tie::IxHash
DIRS := $(shell echo $(MODULES) | sed 's/::[^ ]*//g') \
    Algorithm \
    File \

#------------------------------------------------------------------------------
default:

update: clean
	rm -fr lib
	cpanm -L . -n Capture::Tiny Pegex Text::Diff Tie::IxHash
	cd lib/perl5 && find . -type f | \
	    grep '^\./[A-Z]' | \
	    grep '\.pm' | \
	    cpio -dump ../..
	rm -fr lib

clean:
	rm -fr lib

realclean: clean
	rm -fr $(DIRS:%=%*)
