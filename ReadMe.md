testml-cpp
==========

The C++ runtime support for TestML

# Notes

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
