from __future__ import absolute_import

import re

from testml.util import *

import unittest

from testml.run import TestMLRun

class TestMLRunUnit(TestMLRun):
  @staticmethod
  def run(file):
    TestMLRunUnit().from_file(file).test()

  def __init__(self, **params):
    TestMLRun.__init__(self, **params)

  def testml_begin(self):
    print 'Testing:', self.file
    self.suite = unittest.TestSuite()

  def testml_end(self):
    verbosity = 1
    runner = unittest.TextTestRunner(verbosity=verbosity)
    runner.resultclass = TestResult
    runner.run(self.suite)
    print

  def testml_eq(self, got, want, label):
    self.suite.addTest(testml_case_eq(got, want, label))

  def testml_like(self, got, want, label):
    self.suite.addTest(testml_case_like(got, want, label))

  def testml_has(self, got, want, label):
    self.suite.addTest(testml_case_has(got, want, label))

  def testml_list_has(self, got, want, label):
    self.suite.addTest(testml_case_has(got, want, label))


class testml_case_eq(unittest.TestCase):
  def __init__(self, got, want, label):
    super(testml_case_eq, self).__init__()

    self.got = got
    self.want = want
    self.label = label

  def runTest(self):
    self.assertEqual(self.got, self.want, self.label)


class testml_case_like(unittest.TestCase):
  def __init__(self, got, want, label):
    super(testml_case_like, self).__init__()

    self.got = got
    self.want = want
    self.label = label

  def runTest(self):
    self.assertTrue(re.search(self.want, self.got), self.label)


class testml_case_has(unittest.TestCase):
  def __init__(self, got, want, label):
    super(testml_case_has, self).__init__()

    self.got = got
    self.want = want
    self.label = label

  def runTest(self):
    self.assertTrue(self.want in self.got, self.label)


# See: https://www.pythonsheets.com/notes/python-tests.html#customize-test-report
class TestResult(unittest.TextTestResult):
  pass

#  def addSuccess(self, test):
#    pass

# vim: sw=2:
