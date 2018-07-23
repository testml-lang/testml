#include "testml-bridge.hpp"

TestMLBridge::TestMLBridge() {
  bind("add", this, &TestMLBridge::add);
  bind("sub", [](int a, int b) {
    return a - b;
  });
}

int TestMLBridge::add(int a, int b) {
  return a + b;
}

