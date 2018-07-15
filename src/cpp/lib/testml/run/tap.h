#pragma once

#include "tap.h"
#include "../run.h"

#include <string>

class TestML_Run_TAP :public TestML_Run {
  public:
    TestML_Run_TAP(): TestML_Run() {}
    static void run(std::string file);
};
