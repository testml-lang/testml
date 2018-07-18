#pragma once

#include <string>
#include "../../ext/nlohmann/json.hpp"

namespace testml {

  class Runtime {
    using json = nlohmann::json;

  public:
    Runtime(std::string const& filename);
    virtual ~Runtime() = 0;

    void run();

  private:
    // toplevel methods
    void each_pick(json::array_t list, json::array_t expr);
    void pick_exec(json::array_t list, json::array_t expr);

  private:
    // other methods
    json exec_expr(json::array_t fragment);
    json exec_dot(json::array_t fragment);
    json call_bridge(std::string const& name, json::array_t args);
    json get_point(std::string const& name);

  private:
    void assert_eq(json::array_t got, json::array_t want, std::string const& label);

  private:
    bool is_function(json value);

  protected:
    // those methods are to be overriden by the runtime class implementing
    virtual void testml_eq(json want, json got, std::string const& label) = 0;

  private:
    json _ast;
    json _data;
    json _currentBlock; /* TODO ptr or smth */
  };

}
