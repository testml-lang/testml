#pragma once

#include "../runtime.hpp"

#include <string>

namespace testml {
namespace run {

  class TAP : public Runtime {
    using json = nlohmann::json;
    using Runtime::Runtime;

  protected:
    void testml_eq(json want, json got, std::string const& label) override;

  private:
    void tap_pass(std::string const& label);
    void tap_fail(std::string const& label);

  private:
    int count = 0;
  };

}
}
