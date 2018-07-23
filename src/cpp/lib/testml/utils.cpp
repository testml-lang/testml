#include "utils.hpp"

namespace testml {
namespace utils {

  bool is_all_lowercase(std::string const& s) {
    return std::all_of(s.begin(), s.end(),
      [](char c) { return std::islower(c); }
    );
  }

  bool is_all_uppercase(std::string const& s) {
    return std::all_of(s.begin(), s.end(),
      [](char c) { return std::isupper(c); }
    );
  }

}
}
