# -*- coding: utf8 -*-

import re, sys

from testml.run import TestMLRun

class TestMLRunTAP(TestMLRun):
  @staticmethod
  def run(file):
    TestMLRunTAP().from_file(file).test()

  def __init__(self, **params):
    TestMLRun.__init__(self, **params)
    self.count = 0

  def testml_begin(self):
    self.checked = False
    self.planned = False

  def testml_end(self):
    if not self.planned:
      self.tap_done()

  def testml_eq(self, got, want, label):
    self.check_plan()

    if isinstance(want, basestring) and \
      got != want and \
      re.search(r'\n', want) and (
        self.getv('Diff') or
        self.getp('DIFF')
      ):

      import difflib

      self.tap_fail(label)

      diff = ''
      for line in difflib.unified_diff(
        want.splitlines(True), got.splitlines(True),
        'want', 'got', n=3
      ): diff += line

      self.tap_diag(diff)

    else:
      self.tap_is(got, want, label)

  def testml_like(self, got, want,label):
    self.check_plan()
    self.tap_like(got, want, label)

  def testml_has(self, got, want, label):
    self.check_plan()
    self.tap_has(got, want, label)

  def testml_list_has(self, got, want, label):
    self.check_plan()
    self.tap_has(got, want, label)

  def check_plan(self):
    if self.checked: return
    self.checked = True

    plan = self.vars.get('Plan')
    if plan:
      self.planned = True
      self.tap_plan(plan)

  def tap_plan(self, plan):
    print("1..%d" % plan)

  def tap_pass(self, label):
    self.count += 1
    if label: label = ' - ' + label
    print("ok %d%s" % (self.count, label.encode('utf-8')))

  def tap_fail(self, label):
    self.count += 1
    if label: label = ' - ' + label
    print("not ok %d%s" % (self.count, label.encode('utf-8')))

  def tap_ok(self, ok, label):
    if ok:
      self.tap_pass(label)

    else:
      self.tap_fail(label)

  def tap_is(self, got, want, label):
    if got == want:
      self.tap_pass(label)

    else:
      self.tap_fail(label)

      if label:
        print >> sys.stderr, "#   Failed test '%s'" % label

      else:
        print >> sys.stderr, "#   Failed test"

      if isinstance(got, basestring):
        got = re.sub(r'^', '# ', got)
        got = re.sub(r'^\#\ ', '', got)
        got = re.sub(r'\n$', "\n# ", got)
        got = "'%s'" % got
      print >> sys.stderr, "#          got: %s" % got

      if isinstance(want, basestring):
        want = re.sub(r'^', '# ', want)
        want = re.sub(r'^\#\ ', '', want)
        want = re.sub(r'\n$', "\n# ", want)
        want = "'%s'" % want
      print >> sys.stderr, "#     expected: %s" % want

  def tap_like(self, got, want, label):
    if re.search(want, got):
      self.tap_pass(label)
    else:
      self.tap_fail(label)

  def tap_has(self, got, want, label):
    if want in got:
      self.tap_pass(label)
    else:
      self.tap_fail(label)


  def tap_note(self, msg):
    print >> sys.stdout, re.sub(r'^', '# ', msg, flags=re.M)

  def tap_diag(self, msg):
    print >> sys.stderr, re.sub(r'^', '# ', msg, flags=re.M)

  def tap_done(self):
    print("1..%s" % self.count)

# vim: sw=2:
