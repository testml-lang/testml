#include <iostream>
#include "../lib/testml/run/tap.hpp"


int main(int argc, char* argv[]) {

  testml::run::TAP tap{argv[1]};
  tap.run();

  return 0;
}
