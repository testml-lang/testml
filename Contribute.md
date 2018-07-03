Developers Guide to Contributing to TestML
==========================================

TestML is an extremely ambitious project. We intend to serve every programming
language and existing test framework that we can. We need your help!

If you see missing functionality in a language or framework, please consider
becoming a contributor. It's not that hard, it's really a lot of fun, and there
are others to help you do it.

# Getting Started

The first thing you should do is have a chat with the other developers. We
would love to meet you and help get you started. If you use IRC, please `/join
#testml` on irc.freenode.net. If you've never used IRC, just click this link:
https://webchat.freenode.net/ and you can try it in your browser!

Next you should clone this repository and run the tests:
```
git clone git@github.com:testml-lang/testml
cd testml
make test
```

## TestML Dependencies

It's likely that you'll be missing some dependencies. There really aren't too
many. Have a look at .bin/install-debian-prereqs to see what's needed on a
clean debian install. Here's a short list, most important first:

* Bash
* GNU `make`
* git 2.7 or higher
  * Used for many things beyond cloning the repo
* Recent NodeJS
  * TestML reference compiler is currently written in NodeJS
* Perl(5) 5.14 or higher
  * Some tests use perl as the testml runtime
* Perl CPAN modules: `boolean` and `Capture::Tiny`
* Python(2), Perl(6)
  * Other current TestML runtimes

You don't need all these things to _use_ TestML, but they are useful for
development.

## Use the `Makefile`

Makefiles are the key to working efficiently in the TestML repo. Try:
```
make help
```

This will give you a summary of all the top level `make` commands. Next try:
```
make work
make status
```

The `make work` command will populate your testml with lots of subdirectories
containing the various parts of the TestML project. There are over 15 component
branches currently!

Running `make status` (or simply `make`) is a simple way to see the state of
all your work at once.

Running `make realclean` will remove all the extra subdirs. Make sure you've
committed everything you want to keep first. Always check first with `make
status`.
