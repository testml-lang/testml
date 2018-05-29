import re, sys

class TAP:
  def __init__(self):
    self.count = 0

  def passed(self, label):
    self.count += 1
    print "ok %d - %s" % (self.count, label)

  def failed(self, label):
    self.count += 1
    print "not ok %d - %s" % (self.count, label)

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

  def diag(self, msg):
    print >> sys.stderr, re.sub(r'^', '# ', msg, flags=re.M)

  def done_testing(self):
    print "1..%s" % self.count

# vim: sw=2:
