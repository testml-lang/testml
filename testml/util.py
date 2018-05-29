import sys
import collections

def is_list(o):
  return isinstance(o, collections.Sequence) and \
    not isinstance(o, basestring)

def die(msg):
  print "Died: %s" % msg
  sys.exit(1)

def xxx(o):
  import yaml
  print yaml.dump(o)
  sys.exit(1)

def yyy(o):
  import yaml
  print yaml.dump(o)
  return o

# A constant for when None is the actual intended value:
TESTML_NONE = []

__all__ = [
  "TESTML_NONE",
  "die",
  "is_list",
  "xxx",
  "yyy",
]

# vim: sw=2:
