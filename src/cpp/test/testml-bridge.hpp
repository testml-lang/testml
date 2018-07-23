#pragma once

#include "../lib/testml/bridge.hpp"

class TestMLBridge : public testml::Bridge {
public:
  TestMLBridge();

public:
  int add(int a, int b);
};
