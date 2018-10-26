#! bash

set -e -u

TestMLBridge.add() {
  echo $(($1 + $2))
}

TestMLBridge.sub() {
  echo $(($1 - $2))
}
