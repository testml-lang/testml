#include <iostream>
#include "../lib/testml/run/tap.h"


int main(int argc, char* argv[]) {

  std::string file(argv[1]);
//   TestML_Run_TAP tap;
//   std::string f("asdf");

  TestML_Run_TAP::run(file);
//   tap.run();

  return 0;
}
