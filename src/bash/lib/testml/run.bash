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

TestML.Run.assert-any-ne-any() {
  "$(TestML.Run.tester).testml-ne" "$@"
}

TestML.Run.assert-any-like-any() {
  "$(TestML.Run.tester).testml-like" "$@"
}

TestML.Run.get-label() {
  local label=${1-}

  if [[ -z $label && -n ${TestML_block-} ]]; then
    label=$("TestML.block:$TestML_block:Label")

  elif [[ $label =~ \+ ]]; then
    if [[ -n ${TestML_block-} ]]; then
      label=${label/+/$("TestML.block:$TestML_block:Label")}

    else
      die "Can't use '+' in label when there are no data blocks"
    fi
  fi

  while [[ $label =~ \{\*([-a-z0-9]+)\} ]]; do
    local var=${BASH_REMATCH[1]}
    local val; val=$("TestML.block:$TestML_block:$var")
    label=${label/\{\*$var\}/$val}
  done

  label=${label:+ - $label}

  echo "$label"
}
