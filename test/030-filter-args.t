#!/usr/bin/env testml-boot

Diff = 1
*input.compile == *output

=== Point as call arg
--- input
*a.add(*b) == *c

--- output
{ "testml": "0.3.0",
  "code": ["=>",[],
    ["%()",["*a","*b","*c"],
      ["==",
        [".",
          ["*","a"],
          ["add",
            ["*","b"]]],
        ["*","c"]]]],
  "data": []}



=== Multiple arguments
--- input
add(1, 3, 5) == 9

--- output
{ "testml": "0.3.0",
  "code": ["=>",[],
    ["==",
      ["add",1,3,5],
      9]],
  "data": []}

# vim: ft=:
