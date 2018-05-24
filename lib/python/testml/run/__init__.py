import json, os, re, sys

from testml.util import *

class TestMLRun:
  vtable = {
    '=='    : 'assert_eq',
    '~~'    : 'assert_has',
    '=~'    : 'assert_like',

    '%()'   : 'pick_loop',
    '.'     : 'exec_expr',

    "$''"   : 'get_str',
    '*'     : 'get_point',
    '='     : 'set_var'
  }

  def __init__(self, **params):
    testml = params.get('testml', {})

    self.file = params.get('file')
    self.version = testml.get('testml')
    self.code = testml.get('code')
    self.data = testml.get('data')
    self.bridge = params.get('bridge')
    self.stdlib = params.get('stdlib')
    self.vars = {}

  def from_file(self, file):
    self.file = file

    testml = json.loads(open(file).read())

    self.version = testml.get('testml')
    self.code = testml.get('code')
    self.data = testml.get('data')

    return self

  def test(self):
    self.initialize()

    self.test_begin()

    self.exec_func([], self.code)

    self.test_end()

  #----------------------------------------------------------------------------
  def getp(self, name):
    if not self.block:
      return
    return self.block.point.get(name)

  def getv(self, name):
    return self.vars.get(name)

  def setv(self, name, value):
    self.vars[name] = value

  #----------------------------------------------------------------------------
  def exec_(self, expr, context=[]):
    if not is_list(expr) or \
      is_list(expr[0]) or \
      isinstance(expr[0], basestring) and \
      re.match(r'^(?:=>|\/|\?|\!)$', expr[0]): return [expr]

    args = list(expr)
    opcode = name = args.pop(0)
    call = self.vtable.get(opcode)
    if call:
      return_ = getattr(self, call)(*args)

    else:
      args = list(map(
        (lambda x: self.exec_(x)[0] if is_list(x) else x),
        list(args)))

      context_ = list(context)
      context_.reverse()
      for item in context_:
        args.insert(0, item)

      if re.search(r'^[a-z]', name):
        call = getattr(self.bridge, name)
        if not call:
          die("Can't find bridge function: '%s'" % name)
        return_ = call(*args)

      elif re.search(r'^[A-Z]', name):
        call = getattr(self.stdlib, name.lower())
        if not call:
          die("Can't find TestML Standard Library function: '%s'" % name)
        return_ = call(*args)

      else:
        die("Can't resolve TestML function '%s'" % name)

    return [] if return_ is None else [return_]

  def exec_func(self, context, function):
    signature = function.pop(0)

    for statement in function:
      self.exec_(statement)

  def exec_expr(self, *args):
    context = []

    for call in args:
      context = self.exec_(call, context)

    if len(context): return context[0]

  def pick_loop(self, list_, expr):
    for block in self.data:
      pick = True
      for point in list_:
        if (re.match(r'\*', point) and not block.point.get(point[1:])) or \
           (re.match(r'\!\*', point) and block.point.get(point[2:])):
          pick = False
          break

      if pick:
        self.block = block
        self.exec_(expr)

    self.block = None

  def get_str(self, string):
    string = re.sub(
      r'\{([\-\w+])\}',
      lambda m: self.vars.get(m.group(1), '').__repr__(),
      string,
    )

    string = re.sub(
      r'\{\*([\-\w+])\}',
      lambda m: self.block.point.get(m.group(1), '').__repr__(),
      string
    )

    return string

  def get_point(self, name):
    return self.getp(name)

  def set_var(self, name, expr):
    self.vars[name] = self.exec_(expr)[0]

  def assert_eq(self, left, right, label_expr=''):
    got = self.exec_(left)[0]

    want = self.exec_(right)[0]

    label = self.get_label(label_expr)

    self.test_eq(got, want, label)

  #----------------------------------------------------------------------------
  def initialize(self):
    self.code.insert(0, [])

    self.data = list(map(
      (lambda x: TestMLBlock(x)),
      self.data))

    if not self.bridge:
      bridge_module = __import__(os.environ['TESTML_BRIDGE'])
      self.bridge = (bridge_module.TestMLBridge)()

    if not self.stdlib:
      from testml.stdlib import StdLib
      self.stdlib = StdLib()

  def get_label(self, label_expr=''):
    label = self.exec_(label_expr)[0]

    if not label:
      label = self.getv('Label')
      if not label:
        label = ''
      if re.search(r'\{\*?[\-\w]+\}', label):
        label = self.exec_(["$''", label])[0]

    block_label = self.block.label

    if label:
      label = re.sub(r'^\+', block_label, label)
      label = re.sub(r'\+$', block_label, label)
      label = re.sub(r'\{\+\}', block_label, label)
    else:
      label = block_label

    return label

#------------------------------------------------------------------------------
class TestMLBlock:
  def __init__(self, obj):
    self.label = obj['label']
    self.point = obj['point']

# vim: ft=python sw=2:
