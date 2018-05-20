from testml.bridge import TestMLBridge as Base

class TestMLBridge(Base):
  def add(self, x, y):
    return x + y

  def sub(self, x, y):
    return x - y

  def cat(self, x, y):
    return x + y
