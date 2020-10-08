TestML
======

An Acmeist Data-Driven Software Testing Language

[![Build Status](https://travis-ci.org/testml-lang/testml.svg?branch=master)](https://travis-ci.org/testml-lang/testml)

# Synopsis

Try [Interactive TestML](http://testml.org/playground/)

Run: `make test` to see all the TestML test suites run in all the supported
languages.

An example TestML file, `math.tml`:
```
#!/usr/bin/env testml

"+ - {*a} + {*a} == {*c}":
  *a.add(*a) == *c
"+ - {*c} - {*a} == {*a}":
  *c.sub(*a) == *a
"+ - {*a} * 2 == {*c}":
  *a.mul(2) == *c
"+ - {*c} / 2 == {*a}":
  *c.div(2) == *a
"+ - {*a} * {*b} == {*d}":
  mul(*a, *b) == *d

=== Test Block 1
--- a: 3
--- c: 6

=== Test Block 2
--- a: -5
--- b: 7
--- c: -10
--- d: -35
```

could be run to test a math software library written in any language. This
particular test makes 9 assertions.

To run the test, let's say in Raku, use any of these:
```
testml -R raku math.tml
testml-raku math.tml
TESTML_RUN=raku prove -v math.tml
```

The output would look something like this:
```
foo.tml ..
ok 1 - Test Block 1 - 3 + 3 == 6
ok 2 - Test Block 2 - -5 + -5 == -10
ok 3 - Test Block 1 - 6 - 3 == 3
ok 4 - Test Block 2 - -10 - -5 == -5
ok 5 - Test Block 1 - 3 * 2 == 6
ok 6 - Test Block 2 - -5 * 2 == -10
ok 7 - Test Block 1 - 6 / 2 == 3
ok 8 - Test Block 2 - -10 / 2 == -5
ok 9 - Test Block 2 - -5 * 7 == -35
1..9
ok
All tests successful.
Files=1, Tests=9,  1 wallclock secs ( 0.02 usr  0.00 sys +  0.60 cusr  0.06 csys =  0.68 CPU)
Result: PASS
```

# Description

TestML is a language for writing data driven tests for software written in most
modern programming languages.

You define sections of data called blocks, that define pieces of data called
points. A data point is either an input or an expected output, or sometimes
both.

You also define assertions that are run against the data blocks. For example,
this assertion:
```
*in.transform == *out
```

does the following steps:

* For each data block
* If the block has an `in` point and an `out` point
* Call a "bridge" method named `transform` passing the `in` point's data
* Compare the output of `transform` to the `out` point's data
* Tell the test framework to report a "pass" or "fail"

The bridge code is written in the language of the software you are testing. It
acts as a connection between the language agnostic TestML and the software you
are testing.

It is common for a data block to define many related data points, and then use
different input/output pairs of points for different test assertions.

# Installation

```
git clone git@github.com:testml-lang/testml
source testml/.rc
```

## Development Installation

If you want to be a TestML developer, you'll need to install all the languages
and bin tools needed to run `make test`. You can run this on a Debian/Ubuntu
installation:
```
.bin/install-debian-prereqs
```

NOTE: This has only been tested on Ubuntu 16.04 so far. Be careful.

Otherwise you'll need to do the basic steps in that file.

See "Hacking on TestML" below.

# Hacking on TestML

TestML needs language experts (like you) to port the code to all modern
programming languages. It's only a few hundred lines of (say, Python) code to
port, so it should be easy, right?

To get started, you might want to drop by #testml on irc.freenode.net. We'll be
waiting for you.

## Repository Layout

The testml repository has about 15 related repositories in one. Each component
has its own branch. To checkout all of them at once (into git worktree subdirs)
run `make work` (from master). To see the current status of them all, run
`make`. To remove all the worktree subdirs, run `make realclean`.

All these branches are related and depend on each other during development.
When you run `make test` (for instance) from a clean master, it will add the
worktrees as necessary to get the parts needed.

...more instructions coming soon...

# TestML Background

TestML ideas started back in 2004. The Perl module Test::Base, used the same
data definition syntax that is still used today.

In 2009, an imperative assertion syntax was added, that could be run in any
programming language. It was called TestML and ported to a few languages.

In 2017, the assertion syntax was reinvented, and a TestML compiler was added.
This made the runtime be much cleaner and easier to port to any language. The
full stack was implemented at OpenResty Inc for internal use only.

Now, in 2018, this work is being rewritten as open source, with the goal of
quickly adding support for all popular programming languages.

One example of a fairly big TestML suite is
https://github.com/yaml/yaml-test-suite

## The TestML Compiler

To use TestML you will need to install the TestML Compiler, which is currently
written in NodeJS. You can install it like this:
```
npm install -g testml-compiler
```

NOTE: To hack on TestML, you won't need to install the compiler because it's
built into the repository. In fact, it's probably better not to, so you know
that you are using the latest code.

## Current Implementation Level

To implement TestML, 2 things need to happen:

* Implement all the TestML language features into the TestML Compiler
* Implement the Runtime in each programming language / test framework

The testml-compiler is fully implemented in both Perl and JavaScript (NodeJS
and Browser) and passing all the compiler tests. The Perl version is default
on server side for performance reasons.

The following language runtimes are all fully implemented and passing all the
runtime tests:

* CoffeeScript - Complete.
* JavaScript - Complete.
* Perl - Complete.
* Python 2 - Complete.
* Python 3 - Complete.
* Raku - Complete.

These languages are in progress, with some tests passing and available in
the master branch:

* Bash - On master. Passing 000-010.
* Go - On master. Passing test 000-040.
* Ruby - On master. Passing test 000-010.

These languages are in various states of development on their own branch:
* C++ - On branch wip/cpp.
* Elixir - On branch wip/elixir.
* Gambas - On branch runtime/gambas.

These languages are planned to happen soon:
* Lua
* Groovy
* Java
* Haskell
* PHP
