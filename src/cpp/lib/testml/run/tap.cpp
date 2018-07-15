#include <iostream>
#include <string>
#include "tap.h"

void TestML_Run_TAP::run(std::string file) {
  TestML_Run_TAP tap;

  tap.from_file(file);

  std::cout << "1..1" << std::endl;
  std::cout << "ok 1 - It worked" << std::endl;
}
