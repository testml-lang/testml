#pragma once

#include <string>

namespace testml {
namespace utils {

  bool is_all_lowercase(std::string const& s);
  bool is_all_uppercase(std::string const& s);

  template<typename T>
  struct remove_first_type
  {
  };

  template<typename T, typename... Ts>
  struct remove_first_type<std::tuple<T, Ts...>>
  {
    typedef std::tuple<Ts...> type;
  };

  template<>
  struct remove_first_type<std::tuple<>>
  {
    typedef std::tuple<> type;
  };

}
}
