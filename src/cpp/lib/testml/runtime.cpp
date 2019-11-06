#include <string>
#include <iterator>
#include <iomanip> // TODO remove
#include <fstream>
#include <stdexcept>
#include <iostream>
#include <functional>

#include "runtime.hpp"
#include "bridge.hpp"
#include "utils.hpp"

[[noreturn]] static void NYI(std::string const& add = "") {
  throw std::runtime_error("Not Yet Implemented, sorry! " + add);
}

using json = nlohmann::json;

namespace testml {

  Runtime::Runtime(std::string const& filename, Bridge& bridge)
    : _bridge{bridge} {

    std::ifstream stream(filename);
    stream >> _ast;

    _data = _ast["data"];
  }

  json Runtime::exec(json expr) {
    json executed = exec_expr(expr);
    return executed.size() > 0 ? executed[0] : static_cast<json>(nullptr);
  }

  json Runtime::exec_expr(json expr) {
    if (!expr.is_array() || expr.size() == 0 || !expr[0].is_string())
      return json::array_t{expr};

    std::string opcode = expr[0];
    expr.erase(expr.begin()); // pop first arg
    json val;
    // TODO vtable
    if (opcode == "%<>") {
      each_pick(expr[0], expr[1]);
      return {}; // no return value
    } else if (opcode == "==") {
      assert_eq(expr[0], expr[1], expr.size() == 3 ? expr[2] : "");
      return {}; // no return value
    } else if (opcode == ".") {
      val = exec_dot(expr);
    } else if (opcode == "*") {
      val = get_point(expr[0]);
    } else if (utils::is_all_lowercase(opcode)) {
      val = call_bridge(opcode, expr);
    } else if (utils::is_all_uppercase(opcode)) {
      NYI("std lib");
    } else if (true) {
      // TODO func
      NYI(opcode);
    } else {
      throw std::runtime_error("Can't resolve TestML function");
    }
    return val.is_null() ? json::array_t{} : json::array_t{val};
  }

  json Runtime::call_bridge(std::string const& name, json::array_t args) {
    std::vector<json> transformed;
    std::transform(args.begin(), args.end(), std::back_inserter(transformed),
      [this](json& j) { return exec(j); });
    return _bridge.call(name, transformed);
  }

  void Runtime::assert_eq(json::array_t left, json::array_t right, std::string const& label) {
    testml_eq(exec_expr(left), exec_expr(right), label);
  }

  json Runtime::get_point(std::string const& name) {
    return _currentBlock["point"][name];
  }

  json Runtime::exec_dot(json::array_t calls) {
    json context = {}; // result of last call

    for (auto call : calls) {
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

  bool Runtime::is_function(json value) {
    if (!value.is_object()) {
      return false;
    }
    if (value.size() < 1) {
      return false;
    }
    return value[0].is_string() && value[0] == "=>";
  }

  void Runtime::test() {
    for (auto& statement : _ast["code"]) {
      exec_expr(statement);
    }
    testml_end();
  }

  Runtime::~Runtime() {
  }

}
