#pragma once

#include "../../ext/nlohmann/json.hpp"

namespace testml {
namespace wrapper {

  template<typename T>
  nlohmann::json cook(T);

  template<typename T>
  T uncook(nlohmann::json);


}
}
