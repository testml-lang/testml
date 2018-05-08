#!/bin/bash

# shellcheck disable=1091

set -e

langs=(perl perl6)

run() {
  echo '----------------------------------------------------------------------'
  (
    set -x
    eval "$@"
  )
}

make clean

(
  run './bin/testml'
  run './bin/testml --help'
  run './bin/testml -h'
  run './bin/testml --version'
  run './bin/testml --env'

  run 'testml-compiler test/010-math.tml'
)

(
  source .rc

  run 'testml'
  run 'testml --help'
  run 'testml -h'
  run 'testml --version'
)

(
  source .rc

  run 'testml -c test/*.tml'
  run 'testml -c -p test/*.tml'
)

for lang in "${langs[@]}"; do
  (
    make clean

    source .rc

    run 'TESTML_LANG=$lang prove -v test/*.tml'
    run 'TESTML_LANG=$lang testml test/*.tml'
    run 'testml -l $lang test/*.tml'
    run 'testml-$lang test/*.tml'
  )
done

cowsay 'ALL CLI TESTS ARE WORKING!!!'
