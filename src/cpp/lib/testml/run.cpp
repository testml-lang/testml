#include <string>
#include <iostream>
#include <fstream>
#include <streambuf>
#include "run.h"

TestML_Run& TestML_Run::from_file(std::string file) {
  std::ifstream ifs(file);
  std::string content( (std::istreambuf_iterator<char>(ifs) ),
                       (std::istreambuf_iterator<char>()  ) );

  // this.version = ...
  // this.code = ...
  // this.data = ...
  return *this;
}
