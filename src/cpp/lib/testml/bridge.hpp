#pragma once

#include <tuple>
#include <utility>
#include <unordered_map>
#include <memory>
#include <stdexcept>
#include <string>

#include "boost/callable_traits/args.hpp"
#include "boost/callable_traits/class_of.hpp"
#include "boost/callable_traits/return_type.hpp"
#include "nlohmann/json.hpp"

#include "utils.hpp"
#include "wrapper.hpp"

namespace testml {

  namespace details {

    using json = nlohmann::json;
    using wrapper::cook;
    using wrapper::uncook;

    namespace ct = boost::callable_traits;

    // we need this details class so that we can have a non-templated value
    // stored in the Bridge _fns map.
    struct FnHolder {
      virtual json call(std::vector<json> const&) = 0;
    };

    // the implementation of a FnHolder, which keeps the types around
    template<typename BridgeT, typename Fn>
    class FnHolderImpl : public FnHolder {
      Fn _fn;
      BridgeT* _bridge;
      static constexpr bool _is_pmf = std::is_member_function_pointer<Fn>::value;
      using RawArg = ct::args_t<Fn>;
      // in case of a PMF, remove the class type from the argument list
      using Arg = std::conditional_t<_is_pmf, typename utils::remove_first_type<RawArg>::type, RawArg>;
      using Ret = ct::return_type_t<Fn>;
      static constexpr std::size_t _num_args = std::tuple_size<Arg>::value;

      // type of the N-th argument that the stored function takes
      template<std::size_t I>
      using ArgType = typename std::tuple_element<I, Arg>::type;

      // uncook each argument to its expected type, and call the function
      // we do SFINAE in the return type, using comma+sizeof() to get a dependance on I.

      // PMF case
      template<std::size_t... I>
      auto call_impl(std::vector<json> const& args, std::index_sequence<I...>)
      -> typename std::enable_if<(sizeof...(I), _is_pmf), Ret>::type {
        return (_bridge->*_fn)(uncook<ArgType<I>>(args[I])...);
      }

      // non-PMF case (BridgeT = nullptr_t)
      template<std::size_t... I>
      auto call_impl(std::vector<json> const& args, std::index_sequence<I...>)
      -> typename std::enable_if<(sizeof...(I), !_is_pmf), Ret>::type {
        return _fn(uncook<ArgType<I>>(args[I])...);
      }

    public:
      FnHolderImpl(BridgeT* bridge, Fn fn)
        : _fn{std::move(fn)},
          _bridge{bridge} {
      }

      // check arity and call the function using our little helper, before wrapping it back to json
      json call(std::vector<json> const& args) override {
        if (args.size() != _num_args) {
          throw std::runtime_error("Bridge method call with wrong arity, expected " + std::to_string(_num_args) + ", got " + std::to_string(args.size()) + ".");
        }

        return cook(call_impl(args, std::make_index_sequence<_num_args>{}));
      }

    };

  }

  class Bridge {
    // store a wrapper FnHolder in the map, with FnHolderImpl to keep the correct types around and do FFI correctly
    std::unordered_map<std::string, std::unique_ptr<details::FnHolder>> _fns;

  public:
    template<typename BridgeT, typename Fn>
    auto bind(std::string const& name, BridgeT* obj, Fn fn)
    -> typename std::enable_if<std::is_member_function_pointer<Fn>::value, void>::type {
      static_assert(std::is_same<details::ct::class_of_t<Fn>, BridgeT>::value, "Bridge subclass must pass itself");

      using HolderType = details::FnHolderImpl<BridgeT, Fn>;
      _fns[name] = std::make_unique<HolderType>(obj, std::move(fn));
    }

    template<typename Fn>
    auto bind(std::string const& name, Fn fn)
    -> typename std::enable_if<!std::is_member_function_pointer<Fn>::value, void>::type {
      using HolderType = details::FnHolderImpl<std::nullptr_t, Fn>;
      _fns[name] = std::make_unique<HolderType>(nullptr, std::move(fn));
    }

    nlohmann::json call(std::string const& name, std::vector<nlohmann::json> const& args);
  };

}
