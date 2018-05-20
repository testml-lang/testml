import re

from testml.run import TestMLRun
from testml.tap import TAP

class TestMLRunTAP(TestMLRun):
  @staticmethod
  def run(file):
    TestMLRunTAP().from_file(file).test()

  def __init__(self, **params):
    TestMLRun.__init__(self, **params)
    self.tap = TAP()

  def test_begin(self):
    pass

  def test_end(self):
    self.tap.done_testing()

  def test_eq(self, got, want, label):
    if isinstance(want, basestring) and \
      got != want and \
      re.search(r'\n', want) and (
        self.getv('Diff') or
        self.getp('DIFF')
      ):

      import difflib

      self.tap.failed(label)

      diff = ''
      for line in difflib.unified_diff(
        want.splitlines(True), got.splitlines(True),
        'want', 'got', n=3
      ): diff += line

      self.tap.diag(diff)

    else:
      self.tap.is_eq(got, want, label)

# vim: ft=python sw=2:
