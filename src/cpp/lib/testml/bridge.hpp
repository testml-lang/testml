#pragma once

#include <tuple>
#include <utility>
#include <unordered_map>
#include <memory>
#include <stdexcept>
#include "../../ext/nlohmann/json.hpp"

namespace testml {
  
  namespace details {

    using json = nlohmann::json;

    // we need this details class so that we can have a non-templated value
    struct FnHolder {
      virtual json call(std::vector<json> const&) = 0;
    };

    template<typename Ret, typename... Arg>
    class FnHolderImpl : public FnHolder {
      using Fn = Ret(*)(Arg...);
      Fn _fn;

      // type of the N-th argument that the stored function takes
      template<std::size_t>
      using ArgType = std::tuple_element<I, std::tuple<Arg...>>;

      // uncook each argument to its expected type, and call the function
      template<std::size_t... I>
      Ret call_impl(std::vector<json> const& args, std::index_sequence<I...>) {
        return _fn(uncook<ArgType<I>>(args[I]), ...);
      }

    public:
      FnHolderImpl(Fn fn) : _fn{std::move(fn)} {
      }

      // check arity and call the function using our little helper, before wrapping it back to json
      json call(std::vector<json> const& args) override {
        if (args.size() != sizeof...(Arg)) {
          throw new std::runtime_error("Bridge method call with wrong arity, expected " + sizeof...(Arg) + ", got " + args.size() + ".");
        }

        return cook(_call(args, std::make_index_sequence<sizeof...(Arg)>{}));
      }

    };

  }

  class Bridge {
    std::unordered_map<std::string, std::unique_ptr<details::FnHolder>> _fns;

  public:
    template<typename Fn>
    void register(std::string const& name, Fn&& fn) {
      _fns[name] = std:make_unique<details::FnHolderImpl>(std::move(fn));
    }

    json call(std::string const& name, std::vector<json> const& args) override {
      auto it = _fns.find(name);
      if (it == _fns.end()) {
        throw new std::runtime_error("Bridge method not found: " + name + ".");
      }
      return it->call(args);
    }
  };

}
