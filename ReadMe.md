TestML
======

An Acmeist Data-Driven Software Testing Language

[![Build Status](https://travis-ci.org/testml-lang/testml.svg?branch=master)](https://travis-ci.org/testml-lang/testml)

# Synopsis

Try [Interactive TestML](http://testml.org/playground/)

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

To run the test, let's say in Perl 6, use any of these:
```
testml -R perl6 math.tml
testml-perl6 math.tml
TESTML_RUN=perl6 prove -v math.tml
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

* For each block
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

# TestML Background

TestML ideas started back in 2004. The Perl module Test::Base, used the same
data definition syntax that is still used today.

In 2009, an imperative assertion syntax was added, that could be run in any
programming language. It was called TestML and ported to a few languages.

In 2017, the assertion syntax was reinvented, and a TestML compiler was added.
This made the runtime be much cleaner and easier to port to any language. The
full stack was implemented at OpenResty Inc for internal use only.

Now, in 2018, this work is being rewitten as open source, with the goal of
quickly adding support for all popular programming languges.

One example of a fairly big TestML suite is
https://github.com/yaml/yaml-test-suite

To see a lot of TestML CLI invocations being run, try this command:
```
test/test-cli.sh
```

## The TestML Compiler

To use TestML you will need to install the TestML Compiler, which is currently
written in NodeJS. You can install it like this:
```
npm install -g testml-compiler
```

## Current Implementation Level

To implement TestML, 2 things need to happen:

* Implement all the TestML language features into the TestML Compiler
* Implement the Runtime in each programming language / test framework

To date, the basic data language and the minimal assertion syntax can compile.
Runtime support is as follows:

* CoffeeScript - Complete. Runs all features presented by the compiler.
* JavaScript - Complete.
* Perl(5) - Complete.
* Perl 6 - Complete.
* Python(2) - Complete.
