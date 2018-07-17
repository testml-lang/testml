testml-cpp
==========

The C++ runtime support for TestML

# Repo Layout

* ReadMe.md
* Makefile
* .travis.yml
* bin/testml-cpp-tap            - Bash program that compiles and runs tests
* lib/testml/bridge.cpp         - TestML::Bridge
* lib/testml/run.{cpp,hpp}      - TestML::Run main runtime class
* lib/testml/run/tap.{cpp,hpp}  - TAP subclass of TestML::Run
* lib/testml/stdlib.cpp         - TestML::StdLib class
* src/testml-run.cpp            - Runner program that gets compiled
* test/testml-bridge.{cpp,hpp}  - User defined bridge class for tests

# Coding Guidelines

The TestML project, while being a seriously useful test framework, is also one
of the first true Acmeist framework attempts. We want to adhere to a coding
style that makes sense as a whole, taking the best ideas from various
languages. We are trying to make the code layouts be as similar as possible
between languages. That way people can more easily engage in parts on the
project that are foreign to them.

Here are the some guidelines. You don't have to follow them all but if you
don't you should have good reasons not to.

* Use file names directories as close as possible to others
* Use same class struture where applicable
* Keep methods in same order
* Strive to do line for line ports, but...
  * ... as things get more granular also use best C++ idioms
* 2 space indentation is used across all the code (where allowed)
* Variables names should be same.
  * `foo-bar` is preferred over `foo_bar`
  * `foo_bar` is preferred over `fooBar`
* If a var name clashes with a keyword, add a `_` to end
  * `class` variable becomes `class_`

# Usage

Try running `make test` in this directory. The test should pass.

Here's what is happening so far under the hood:

* `make` runs: `TESTML_RUN=cpp-tap prove -v test/*.tml`
* `prove` runs `test/010-math.tml`
* The shebang line runs `./bin/testml`
* `testml` sees `TESTML_RUN=cpp-tap` and runs `./bin/testml-cpp-tap`
* The `testml-run-file` function in `./bin/testml-cpp-tap` is called
* C++ compiles surces into `$TESTML_CACHE/testml-run-cpp`
* testml-compiler compiles `test/010-math.tml` into the `$TESTML_CACHE`
* Run the test: `$TESTML_CACHE/testml-run-cpp $TESTML_CACHE/010-math.tml`
* Program produces TAP output and `prove` harnesses it

Things are compiled only if inputs change. Well that's how it should work when
it's done. The runner binary `testml-run-cpp` is compiled using the TestML C++
source files and also the user's `test/testml-bridge.*` C++ files.

Currently the Lingy is not yet being evaluated. The compiled program just
outputs a hard-coded TAP output, to show that the basics are in place.

The next steps are:

* Read and parse the JSON lingy file passed in as argv file name.
* Implement the exec loop functionality.
  * Should be ported from an existing TestML runtime.
