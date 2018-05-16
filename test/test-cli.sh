#!/bin/bash

# shellcheck disable=1091

set -e

runners=(coffee-tap node-tap perl-tap perl6-tap python-tap)

run() {
  echo '----------------------------------------------------------------------'
  (
    set -x
    eval "$@"
  )
}

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

for runner in "${runners[@]}"; do
  (
    source .rc

    run 'TESTML_RUN=$runner prove -v test/*.tml'
    run 'TESTML_RUN=$runner testml test/*.tml'
    run 'testml --run=$runner test/*.tml'
    run 'testml-$runner test/*.tml'
  )
done

cowsay 'ALL CLI TESTS ARE WORKING!!!'
