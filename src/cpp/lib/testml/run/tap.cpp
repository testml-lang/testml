#include <string>
#include <iostream>
#include "tap.hpp"

namespace testml {
namespace run {

  void TAP::testml_eq(json want, json got, std::string const& label) {
    if (want == got) {
      tap_pass(label);
    } else {
      tap_fail(label);
    }
  }

  void TAP::tap_pass(std::string const& label) {
    std::cout << "ok " << ++count;
    if (!label.empty()) {
      std::cout << " - " << label;
    }
    std::cout << "\n";
  }

  void TAP::tap_fail(std::string const& label) {
    std::cout << "not ok " << ++count;
    if (!label.empty()) {
      std::cout << " - " << label;
    }
    std::cout << "\n";
  }

  void TAP::testml_end() {
    std::cout << "1.." << count;
  }

}
}
