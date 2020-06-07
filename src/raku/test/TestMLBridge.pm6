use TestML::Bridge;

class Mine {}

class TestMLBridge is TestML::Bridge {

method hash-lookup($hash, $key) {
  $hash{$key};
}

method get-env($name) {
  %*ENV{$name};
}

method add($x, $y) {
  $x + $y;
}

method sub($x, $y) {
  $x - $y;
}

method cat($x, $y) {
  $x ~ $y;
}

method mine {
  return Mine.new;
}

}
