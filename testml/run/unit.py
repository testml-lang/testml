from __future__ import absolute_import

from testml.util import *

import unittest

from testml.run import TestMLRun

class TestMLRunUnit(TestMLRun):
  @staticmethod
  def run(file):
    TestMLRunUnit().from_file(file).test()

  def __init__(self, **params):
    TestMLRun.__init__(self, **params)

  def test_begin(self):
    self.suite = unittest.TestSuite()

  def test_end(self):
    verbosity = 1
    runner = unittest.TextTestRunner(verbosity=verbosity)
    runner.resultclass = TestResult
    runner.run(self.suite)

  def test_eq(self, got, want, label):
    self.suite.addTest(testml_eq(got, want, label))

class testml_eq(unittest.TestCase):
  def __init__(self, got, want, label):
    super(testml_eq, self).__init__()

    self.got = got
    self.want = want
    self.label = label

  def runTest(self):
    self.assertEqual(self.got, self.want, self.label)

# See: https://www.pythonsheets.com/notes/python-tests.html#customize-test-report
class TestResult(unittest.TextTestResult):
  pass

#  def addSuccess(self, test):
#    pass

# vim: sw=2:
