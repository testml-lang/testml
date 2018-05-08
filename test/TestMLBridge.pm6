use TestML::Bridge;

unit class TestMLBridge is TestML::Bridge;

method add($a, $b) {
  $a + $b;
}

method sub($a, $b) {
  $a - $b;
}
