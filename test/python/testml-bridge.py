import os

from testml.bridge import TestMLBridge as Base

class Mine():
  pass

class TestMLBridge(Base):
  def hash_lookup(self, hash_, key):
    return hash_.get(key)

  def get_env(self, name):
    return os.environ.get(name)

  def add(self, x, y):
    return x + y

  def sub(self, x, y):
    return x - y

  def mine(self):
    return Mine()

  def str_nums(self, str_):
    pass
    # _.map _.split(str_, ' '), (x)-> Number x

