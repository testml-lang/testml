#pragma once

#include <string>

class TestML_Run {
  public:
    TestML_Run () {}
    TestML_Run& from_file (std::string file);
  private:
    std::string version;
    // typename code;
    // typename data;
};
