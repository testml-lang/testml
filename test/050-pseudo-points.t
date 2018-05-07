#!/usr/bin/env testml-boot

*input.undent.compile == *output

=== Test HEAD
--- input
    === Test 1
    === Test 2
    --- HEAD
    === Test 3

--- output
{ "testml": "0.3.0",
  "code": [],
  "data": [
    { "label": "Test 2",
      "point": {
        "HEAD": true}},
    { "label": "Test 3",
      "point": {}}]}



=== Test LAST
--- input
    === Test 1
    === Test 2
    --- LAST
    === Test 3

--- output
{ "testml": "0.3.0",
  "code": [],
  "data": [
    { "label": "Test 1",
      "point": {}},
    { "label": "Test 2",
      "point": {
        "LAST": true}}]}



=== Test ONLY
--- input
    === Test 1
    === Test 2
    --- ONLY
    === Test 3

--- output
{ "testml": "0.3.0",
  "code": [],
  "data": [
    { "label": "Test 2",
      "point": {
        "ONLY": true}}]}



=== Test SKIP
--- input
    === Test 1
    === Test 2
    --- SKIP
    === Test 3

--- output
{ "testml": "0.3.0",
  "code": [],
  "data": [
    { "label": "Test 1",
      "point": {}},
    { "label": "Test 3",
      "point": {}}]}

# vim: ft=:
