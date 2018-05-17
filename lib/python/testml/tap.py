import re, sys

class TAP:
  def __init__(self):
    self.count = 0

  def is_eq(self, got, want, label):
    self.count += 1

    if got == want:
      print "ok %d - %s" % (self.count, label)

    else:
      print "not ok %d - %s" % (self.count, label)

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

  def done_testing(self):
    print "1..%s" % self.count
