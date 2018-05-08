#!/bin/sh

set -e

run() {
  echo '----------------------------------------------------------------------'
  (
    set -x
    eval "$@"
  )
}

(
  make clean

  run './bin/testml'
  run './bin/testml --help'
  run './bin/testml -h'
  run './bin/testml --version'
)

(
  make clean

  source .rc

  run 'testml'
  run 'testml --help'
  run 'testml -h'
  run 'testml --version'
)

(
  make clean

  source .rc

  run 'testml-compiler test/010-math.tml'
  run 'testml -c -p test/*.tml'

  run 'TESTML_LANG=perl prove -v test/*.tml'
  run 'TESTML_LANG=perl testml test/*.tml'
  run 'testml -l perl test/*.tml'
  run 'testml-perl test/*.tml'
)

run 'echo ALL CLI TESTS ARE WORKING'
