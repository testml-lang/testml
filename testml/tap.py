# -*- coding: utf8 -*-

import re, sys

class TAP:
  def __init__(self):
    self.count = 0

  def plan(self, plan):
    print "1..%d" % plan

  def passed(self, label):
    self.count += 1
    if label: label = ' - ' + label
    print "ok %d%s" % (self.count, label.encode('utf-8'))

  def failed(self, label):
    self.count += 1
    if label: label = ' - ' + label
    print "not ok %d%s" % (self.count, label.encode('utf-8'))

  def ok(self, ok, label):
    if ok:
      self.passed(label)

    else:
      self.failed(label)

  def is_eq(self, got, want, label):
    if got == want:
      self.passed(label)

    else:
      self.failed(label)

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

  def like(self, got, want, label):
    if re.search(want, got):
      self.passed(label)
    else:
      self.failed(label)

  def has(self, got, want, label):
    if want in got:
      self.passed(label)
    else:
      self.failed(label)


  def note(self, msg):
    print >> sys.stdout, re.sub(r'^', '# ', msg, flags=re.M)

  def diag(self, msg):
    print >> sys.stderr, re.sub(r'^', '# ', msg, flags=re.M)

  def done_testing(self):
    print "1..%s" % self.count

# vim: sw=2:
