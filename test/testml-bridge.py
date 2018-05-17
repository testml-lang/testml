from testml.util import *
from testml.bridge import TestMLBridge as Base

class TestMLBridge(Base):
  def add(self, a, b):
    return a + b

  def sub(self, a, b):
    return a - b

