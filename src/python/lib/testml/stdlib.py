import os, sys, re

from testml.util import *

class TestMLError():
  def __init__(self, msg):
    self.msg = msg

class StdLib():
  def __init__(self, run):
    self.run = run

  def argv(self):
    return sys.argv

  def block(self, selector=None):
    if selector is None:
      return self.run.block

    for block in self.run.data:
      if block['label'] == selector:
        return block

  def blocks(self):
    return list(self.run.data)

  def bool(self, value):
    return not(value is None or value is False)

  def cat(self, *strings):
    if type(strings[0]).__name__ == 'list':
      strings = strings[0]
    return ''.join(strings)

  def count(self, list_):
    return len(list_)

  def env(self):
    return dict(os.environ)

  def error(self, msg=''):
    return TestMLError(msg)

  def false(self):
    return False

  def join(self, list_, separator=' '):
    return separator.join(list_)

  def lines(self, text):
    return re.sub(r'\n$', '', text).split('\n')

  def list(*values):
    return values

  def msg(self, error):
    return error.msg

  def none(self):
    return self.run.Nil

  def null(self):
    return self.run.Null

  def regex(self, pattern, flags=''):
    return re.compile(pattern)

  def split(self, string, delim=' ', limit=-1):
    return string.split(delim, limit)

  def sum(self, *numbers):
    sum_ = 0
    if len(numbers) == 0:
      return sum_
    if type(numbers[0]).__name__ == 'list':
      numbers = numbers[0]
    for n in numbers:
      sum_ += n
    return sum_

  def text(self, list_):
    list_ = list(list_)
    list_.append('')
    return '\n'.join(list_)

  def throw(self, error=''):
    raise Exception(error)

  def true(self):
    return True

  def type(self, value):
    return self.run.type_(self.run.cook(value))

# vim: sw=2:
