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

      got = re.sub(r'^', '# ', got)
      got = re.sub(r'^\#\ ', '', got)
      got = re.sub(r'\n$', "\n# ", got)
      print >> sys.stderr, "#          got: '%s'" % got

      want = re.sub(r'^', '# ', want)
      want = re.sub(r'^\#\ ', '', want)
      want = re.sub(r'\n$', "\n# ", want)
      print >> sys.stderr, "#     expected: '%s'" % want

  def done_testing(self):
    print "1..%s" % self.count
