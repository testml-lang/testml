use TestML::Bridge;

unit class TestMLBridge is TestML::Bridge;

method add($x, $y) {
  $x + $y;
}

method sub($x, $y) {
  $x - $y;
}

method cat($x, $y) {
  $x ~ $y;
}
