#include "wrapper.hpp"

namespace testml {
namespace wrapper {

  using json = nlohmann::json;

  template<>
  nlohmann::json cook(std::string s) {
    return nlohmann::json::string_t{s};
  }

  template<>
  nlohmann::json cook(int i) {
    return nlohmann::json::number_integer_t{i};
  }

  template<>
  std::string uncook(nlohmann::json s) {
    return s;
  }

  template<>
  int uncook(nlohmann::json i) {
    return i;
  }

}
}
