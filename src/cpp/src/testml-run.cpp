#include <iostream>
#include <exception>

#include "../lib/testml/run/tap.hpp"

int main(int, char* argv[]) {

  testml::Bridge bridge;
  bridge.bind("add", +[](int a, int b) {
    return a + b;
  });
  bridge.bind("sub", +[](int a, int b) {
    return a - b;
  });
  try {
    testml::run::TAP tap{argv[1], bridge};
    tap.run();
  } catch (std::exception& e) {
    std::cout << "exception thrown: " << e.what() << std::endl;
  }

  return 0;
}
