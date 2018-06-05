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

  def testml_begin(self):
    self.checked = False
    self.planned = False

  def testml_end(self):
    if not self.planned:
      self.tap.done_testing()

  def testml_eq(self, got, want, label):
    self.check_plan()

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

  def testml_like(self, got, want,label):
    self.check_plan()
    self.tap.like(got, want, label)

  def testml_has(self, got, want, label):
    self.check_plan()
    self.tap.has(got, want, label)

  def testml_list_has(self, got, want, label):
    self.check_plan()
    self.tap.has(got, want, label)

  def check_plan(self):
    if self.checked: return
    self.checked = True

    plan = self.vars.get('Plan')
    if plan:
      self.planned = True
      self.tap.plan(plan)

  def out(self, msg):
    self.tap.note(msg)

  def err(self, msg):
    self.tap.diag(msg)

# vim: sw=2:
