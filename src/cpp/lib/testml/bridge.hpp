#pragma once

#include <tuple>
#include <utility>
#include <unordered_map>
#include <memory>
#include <stdexcept>
#include <string>

#include "../../ext/nlohmann/json.hpp"

#include "wrapper.hpp"

namespace testml {

  namespace details {

    using json = nlohmann::json;
    using wrapper::cook;
    using wrapper::uncook;

    // we need this details class so that we can have a non-templated value
    // stored in the Bridge _fns map.
    struct FnHolder {
      virtual json call(std::vector<json> const&) = 0;
    };

    // the implementation of a FnHolder, which keeps the types around
    template<typename Ret, typename... Arg>
    class FnHolderImpl : public FnHolder {
      using Fn = std::function<Ret(Arg...)>;
      Fn _fn;

      // type of the N-th argument that the stored function takes
      template<std::size_t I>
      using ArgType = typename std::tuple_element<I, std::tuple<Arg...>>::type;

      // uncook each argument to its expected type, and call the function
      template<std::size_t... I>
      Ret call_impl(std::vector<json> const& args, std::index_sequence<I...>) {
        return _fn(uncook<ArgType<I>>(args[I])...);
      }

    public:
      FnHolderImpl(Fn fn) : _fn{std::move(fn)} {
      }

      // check arity and call the function using our little helper, before wrapping it back to json
      json call(std::vector<json> const& args) override {
        if (args.size() != sizeof...(Arg)) {
          throw std::runtime_error("Bridge method call with wrong arity, expected " + std::to_string(sizeof...(Arg)) + ", got " + std::to_string(args.size()) + ".");
        }

        // generate an index_sequence so that the call_impl() can spread on each argument
        return cook(call_impl(args, std::make_index_sequence<sizeof...(Arg)>{}));
      }

    };

  }

  class Bridge {
    std::unordered_map<std::string, std::unique_ptr<details::FnHolder>> _fns;

  public:
    template<typename Ret, typename... Arg>
    void bind(std::string const& name, std::function<Ret(Arg...)> fn) {
      // store a wrapper FnHolder in the map, with FnHolderImpl to keep the correct types around and do FFI correctly
      using HolderType = details::FnHolderImpl<Ret, Arg...>;
      _fns[name] = std::make_unique<HolderType>(std::move(fn));
    }

    template<typename Ret, typename... Arg>
    void bind(std::string const& name, Ret(*fn)(Arg...)) {
      bind(name, std::function<Ret(Arg...)>(fn));
    }

    nlohmann::json call(std::string const& name, std::vector<nlohmann::json> const& args);
  };

}
