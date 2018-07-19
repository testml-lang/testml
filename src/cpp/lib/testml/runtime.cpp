#include <string>
#include <iterator>
#include <iomanip> // TODO remove
#include <fstream>
#include <stdexcept>
#include <iostream>
#include <functional>

#include "runtime.hpp"
#include "bridge.hpp"

[[noreturn]] static void NYI(std::string const& add = "") {
  throw std::runtime_error("Not Yet Implemented, sorry! " + add);
}

using json = nlohmann::json;

namespace testml {

  namespace {
    bool is_all_lowercase(std::string const& s) {
      return std::all_of(s.begin(), s.end(), [](char c) { return std::islower(c); });
    }
  }

  Runtime::Runtime(std::string const& filename, Bridge& bridge)
    : _bridge{bridge} {

    std::ifstream stream(filename);
    stream >> _ast;

    _data = _ast["data"];
  }

  json Runtime::exec_expr(json fragment) {
    if (!fragment.is_array() || fragment.size() == 0)
      return json::array_t{fragment};

    // TODO check if the first element is a string, otherwise return it unwrapped

    std::string opcode = fragment[0];
    fragment.erase(fragment.begin()); // pop first arg
    json val;
    if (opcode == "%<>") {
      // TODO bound check
      // TODO std::unordered_map<std::string key, std::tuple<int arity, std::function call>>
      each_pick(fragment[0], fragment[1]);
      return {}; // no return value
    } else if (opcode == "==") {
      assert_eq(fragment[0], fragment[1], fragment.size() == 3 ? fragment[2] : "");
      return {}; // no return value
    } else if (opcode == ".") {
      val = exec_dot(fragment);
    } else if (opcode == "*") {
      val = get_point(fragment[0]);
    } else if (is_all_lowercase(opcode)) {
      val = call_bridge(opcode, fragment);
    } else if (true) {
      NYI(opcode);
    } else {
      throw std::runtime_error("Can't resolve TestML function");
    }
    return val.is_null() ? json::array_t{} : json::array_t{val};
  }

  json Runtime::call_bridge(std::string const& name, json::array_t args) {
    std::vector<json> transformed;
    std::transform(args.begin(), args.end(), std::back_inserter(transformed),
      [this](json& j) { return exec_expr(j)[0] /* TODO exec() */; });
    return _bridge.call(name, transformed);
  }

  json Runtime::get_point(std::string const& name) {
    return _currentBlock["point"][name];
  }

  json Runtime::exec_dot(json::array_t fragment) {
    json context = {}; // result of last call
    
    for (auto call : fragment) {
      // add context right after the opcode
      call.insert(call.begin() + 1 /* after opcode */, context.begin(), context.end());
      // we now have the full argument list
      context = exec_expr(call);
    }
    return context[0];
  }

  void Runtime::each_pick(json::array_t list, json::array_t expr) {
    for (auto& datum : _data) {
      _currentBlock = datum;
      // TODO block.point.ONLY

      pick_exec(list, expr);
    }
    _currentBlock = {};
  }

  void Runtime::pick_exec(json::array_t list, json::array_t expr) {
    // check whether we should run or not
    auto& points = _currentBlock["point"];
    for (json::string_t str : list) {
      if (!str.compare(0, 1, "*") && points.find(str.substr(1)) == points.end()) {
        return;
      }
      if (!str.compare(0, 2, "!*") && points.find(str.substr(2)) != points.end()) {
        return;
      }
    }

    // if we didn't return beforehand, we're safe to run the expression
    if (is_function(expr)) {
      // exec_func
      NYI();
    } else {
      exec_expr(expr);
    }
  }

  void Runtime::assert_eq(json::array_t left, json::array_t right, std::string const& label) {
    testml_eq(exec_expr(left), exec_expr(right), label);
  }

  bool Runtime::is_function(json value) {
    if (!value.is_object()) {
      return false;
    }
    if (value.size() < 1) {
      return false;
    }
    return value[0].is_string() && value[0] == "=>";
  }

  void Runtime::run() {
    for (auto& statement : _ast["code"]) {
      exec_expr(statement);
    }
    testml_done();
  }

  Runtime::~Runtime() {
  }

}
