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
  * The TestML reference compiler is currently written in NodeJS
* Perl 5.14 or higher
  * Some of the framework tests use perl as the TestML runtime
* Python (2 or 3), Raku
  * Other current TestML runtime languages

You don't need all these things to _use_ TestML, but they are useful for
development.

## Use the `Makefile`s

Makefiles are the key to working efficiently in the TestML repo. Try:
```
make help
```

This will give you a summary of all the top level `make` commands.

These are the testing commands:
```
make test                   - Run all tests
make test-runtime-<lang>    - Runtime tests for specific language
make test-compiler          - COmpiler tests
make test-cli               - CLI tests
```

Next try:
```
make work
make status
```

The `make work` command will populate your `testml` with lots of subdirectories
containing the various extra parts of the TestML project. Things like examples,
talks, etc.

Running `make status` (or simply `make`) is a simple way to see the state of
all your work at once.

Running `make realclean` will remove all the extra subdirs. Make sure you've
committed everything you want to keep first. Always check first with `make
status`.

## The TestML Repository

The Git repository for the TestML project is a bit different than most
repositories. It has many independent components that each could be their own
repository. Instead, we currently have everything in one repository, with each
component as a separate (unrelated to one another) branch.

The main component branches are: `compiler/*`, `runtime/*` and `testml/*` for
the compilers, language dependent runtime source code, and language agnostic
TestML test suite respectively. This branches are simultaneously part of the
master branch, so that all development can be done on master (or a fork). We
use the `git-subrepo` to make these branches be both part of master and
logically separate at the same time.

The `compiler/*` and `runtime/*` branches are part of `master` under the `src/`
sub-directory. The `testml/*` branches are under the `test` sub-directory.

* `master`

  The main, top level branch, for installing TestML to use and for coordinating
  the development process. For TestML developers, the Makefile is the main
  interesting thing here.

* `compiler/coffee`

  This is the current TestML reference compiler (aka `testml-compiler`). It is
  written in CoffeeScript/NodeJS/JavaScript and it runs on the server and in
  the browser. Try http://testml.org/playground/?view=compiler

* `compiler/perl`

  The TestML reference compiler is ported to Perl because the NodeJS startup
  time is prohibitively slow.

* `compiler/haskell`

  The TestML reference compiler will eventually be ported to Haskell and
  distributed as precompiled binaries.

* `testml/compiler-tml`

  The TestML compiler test suite (in TestML!).

* `runtime/<language>`

  There are one of these branches for every supported programming language.
  These are the language runtime branches and the place where all the code for
  a specific language goes. Currently there are 6 working languages: `bash`, `coffee`
  (which would be on the `run/coffee` branch), `node`, `perl`, `raku`,
  `python`.

* `testml/runtime-tml`

  The runtime tests (in TestML). Every language runtime passes this same test
  suite. It's a perfect example of a TestML suite working in every language.

* `testml/compiler-tml`

  The compiler tests (in TestML). Every compiler implementation passes this same test
  suite.

* `testml/cli-tml`

  A test suite to test the TestML CLI commands.

* `site` (and `playground` and `gh-pages`)

  These branches build the http://testml.org website and publishes it using
  GitHub Pages.

* `talk/*`

  There is a branch for each conference talk slides given about TestML.

* `eg/*`

  Example programs implemented in many langauges at once to show how TestML is
  used.

* `note`

  A branch of various notes files and to-do lists.

# How TestML Works

At a very abstract level, almost all software tests are made up of:

* Input

  The "before". A starting situation and/or data.

* Output

  The "after". A (expected) result situation and/or data.

* Process

  The software code being tested (using the Input).

* Assertion

  A statement of how the Process result relates to the Output.

These are the 4 things that the TestML language is concerned with. TestML makes
it easy to write a simple assertion involving a process and then apply 1000s of
data variations to it.

Here's an example abstract TestML program (in the file test1.tml) of the above:

    #!/usr/bin/env testml
    *input.process == *output
    === Test 1
    --- input
    --- output
    === Test 2
    --- input
    --- output

You could run this TestML program in Python like this:
```
testml -R python test1.tml
```

This would require a Python class called `testml-bridge.py` that defined a
method called `process`. That method would have one input argument for the
input. It would invoke some part of the Python software you were writing this
test for, and return some output.

When the test was run, `testml` would notice that it hadn't yet been compiled.
It would call `testml-compiler` to compile the program into the file:
`.testml/test1.tml.json`. The compiler output is a simple Lisp-like language
called Lingy, that is encoded in JSON.

Then `testml` would "run" the compiled TestML test file, by evaluating the
Lingy code in Python. It would know how to pass each input to the Bridge Class
method `process` and compare the return value to the expected output. Finally
it would know how to report the test results to the user in the style of the
test framework that the user had chosen. For Python, it would probably be
`unittest.py`.

# How To Add Support for a New Language

Let's say that you wanted to implement TestML support for the (fictitious)
programming language Gumby.

First make a new sub-directory called `src/gumby/`. Now set up the
sub-directory layout to look like this:
```
Makefile                    - Makefile to run your tests (`make test`)
bin/testml-gumby            - A symlink to testml-gumby-tap
   /testml-gumby-tap        - TestML runner for Gumby using TAP
lib/testml/bridge.gum       - Base class for Gumby TestML Bridge Classes
   /testml/run.gum          - The Lingy evalutation runtime code
   /testml/stdlib.gum       - The TestML standard library
   /testml/run/tap.gum      - The TAP subclass of `testml/run.gum`
test/testml-bridge.gum      - TestML bridge class for the `test/run-tml` suite
    /0##-<test-name>.tml    - Symlink files to `../../test/run-tml/<name>.tml`
pkg/Changes                 - A change log file for Gumby module distribtution
pkg/package.mk              - Package distribution Makefile rules
pkg/*                       - Other packaging files
```

That's pretty much it. You should look at another existing language's
`src/<lang>/` branch to see what the file contents should be. I think
`run/coffee` is the simplest to understand. It reads like pseudocode to a
degree. Pick a language that you are most comfortable with.

The `Makefile` and the `bin` files can be copied and slightly modified. The
`bin` program is written in Bash and it has one function called
`testml-run-file`. In a dynamic language like Perl, it simply invokes perl
telling it to call the `TestML::Run::TAP` class's `run` method, passing it the
name of the compiled file. This is the same for Python and JavaScript etc.

For a compiled language like C++ or Go, this bash function would first compile
a testml runner (including the project specific Bridge class being used) and
then call that (new, compiled) program with the name of the compiled TestML
test file.

All the actual Gumby code is in `lib`, and most of it is in `testml/run.gum`.
It is highly encouraged that you write the gumby code to use the exact same
logic and style as all the other implementations. ie If you were porting from
CoffeeScript to Gumby you should try to do a method-for-method, line-for-line,
idiom-for-idiom translation. Even if this ends up not being the best possible
Gumby code, it will help evolve all the implementations in parallel.

Every language needs to write at least one test framework specific subclass. In
this case we chose TAP. So far, we have written a TAP subclass for every
language runtime. That's because TAP itself is programming language agnostic.
But we also have other framework subclasses like `unittest` for Python and
Mocha for NodeJS. The framework subclass is usually not much code.

The TestML Standard Library has all kinds of common data manipulations that can
be expected to be available when using TestML in any programming language.

Finally there is the `test/` directory. You'll need to port the simple bridge
class to Gumby. The rest is just symlinks to the common test suite files.

Once the basic Makefile and bin script is in place, you can just keep running
`make test` and adding more Gumby code until it's all done!

# What Needs to be Done for TestML?

There are many categories of many things that need help for the TestML project.
This section covers the currently most obvious. Look it over and see if any
appeal to you.

To start, you should run `make note` and then look in the `./note/` directory.
Start with `note/Languages` and then read through `note/ToDo`.

A short list of categories:

* New language runtime

  Pick a language that TestML hasn't been ported to and port to it

* New test framework for an existing runtime

  TestML needs a runtime subclass for each popular test framework in a
  language. Hopefully it won't be much code to hook into a framework.

* Port testml-compiler to a new language

  TestML really only needs one compiler (a program in your PATH called
  `testml-compiler` that passes the `test/compiler-tml` suite). Optimally this
  can be compiled and/or condensed to a (single file) platform specific binary
  for all major platforms (at least Linux, Windows, MacOSX). Then a user
  install just needs to download the compiler.

  THe current compiler is written in JavaScript and uses NodeJS on the server.
  It turns out to have a prohibitively slow startup time. A Perl port is
  planned as a quick fix, but ultimately something like Haskell would be best.

* Add tests to the test suites
* Work on the http://testml.org website (`site` branch)
* User documentation and tutorials
