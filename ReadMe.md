TestML
======

An Acmeist Software Testing Language

# Synopsis

An example TestML file, `math.tml`:
```
#!/usr/bin/env testml

*n1.add(*n1) == *a1
*n1.mul(2) == *a1
*a1.div(2) == *n1
*n1.mul(*n2) == *a2

=== Test block 1
--- n1: 3
--- a1: 6

=== Test block 2
--- n1: -5
--- n2: 7
--- a1: -10
--- a2: -35
```

could be run to test a math software library written in any language. This
particular test makes 7 assertions.

To run the test, let's say in Perl:
```
TESTML_LANG=perl prove math.tml
```

# Description

TestML is a language for writing data driven tests for software written in most
modern programming languages.

You define sections of data called blocks, that define pieces of data called
points. A data point is either an input or an output, or sometimes both.

You also define assertions that are run against the data blocks. For example,
this assertion:
```
*in.transform == *out
```

does the following steps:

* For each block
* If the block has an `in` point and an `out` point
* Call a "bridge" method named `transform` passing the `in` data
* Compare the output of `transform` to the `out` point's data
* Tell the test framework to report a "pass" or "fail"

The bridge code is written in the language of the software you are testing. It
acts as a connection between the language agnostic TestML and the software you
are testing.

It is common for a data block to defined many related data points, and then use
different input/output pairs of points for different test assertions.

# Installation

```
git clone git@github.com:testml-lang/testml
source testml/.rc
```
