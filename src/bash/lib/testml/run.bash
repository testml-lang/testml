#! bash

set -e -u -o pipefail

TestML.Run.pick() {
  i=$1; shift
  for point in "$@"; do
    type "TestML.block:$i:${point#\*}" &>/dev/null || return 1
  done
  return 0
}

TestML.Run.assert-any-eq-any() {
  "$(TestML.Run.tester).testml-eq" "$@"
}

TestML.Run.assert-any-like-any() {
  "$(TestML.Run.tester).testml-like" "$@"
}

TestML.Run.get-label() {
  if [[ -z $1 ]]; then
    echo " - $(TestML.block:$TestML_block:Label)"

  elif [[ $1 =~ \+ ]]; then
    if [[ -n ${TestML_block-} ]]; then
      echo " - ${1/+/$(TestML.block:$TestML_block:Label)}"
    else
      die "Can't use '+' in label when there are no data blocks"
    fi
  else
    echo " - $1"
  fi
}
