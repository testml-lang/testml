#include "bridge.hpp"

namespace testml {

  using json = nlohmann::json;

  json Bridge::call(std::string const& name, std::vector<json> const& args) {
    auto it = _fns.find(name);
    if (it == _fns.end()) {
      throw std::runtime_error("Bridge method not found: " + name + ".");
    }
    return it->second->call(args);
  }

}
