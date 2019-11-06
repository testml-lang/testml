#include <iostream>
#include <exception>

#include "../lib/testml/run/tap.hpp"
#include "../test/testml-bridge.hpp"

int main(int, char* argv[]) {

  TestMLBridge bridge;
  try {
    testml::run::TAP tap{argv[1], bridge};
    tap.test();
  } catch (std::exception& e) {
    std::cout << "exception thrown: " << e.what() << std::endl;
  }

  return 0;
}
