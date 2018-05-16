from testml.run import TestMLRun
from testml.tap import TAP

class TestMLRunTAP(TestMLRun):
  @staticmethod
  def run(file):
    TestMLRunTAP().from_file(file).test()

  def __init__(self, testml=None, bridge=None):
    TestMLRun.__init__(self, testml, bridge)

    self.tap = TAP()

  def test_begin(self):
    pass

  def test_end(self):
    self.tap.done_testing()

  def test_eq(self, got, want, label):
    self.tap.is_eq(got, want, label)
