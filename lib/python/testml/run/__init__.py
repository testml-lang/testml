import json, os, re, sys

from testml.util import *

operator = {
  '=='    : 'eq',
  '.'     : 'call',
  '=>'    : 'func',
  "$''"   : 'get-string',
  '%()'   : 'pickloop',
  '*'     : 'point',
  '='     : 'set-var'
}

class TestMLRun:
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

    self.exec_(self.code)

    self.test_end()

  #----------------------------------------------------------------------------
  def getp(self, name):
    if not self.block:
      return
    return self.block.point[name]

  def getv(self, name):
    return self.vars[name]

  def setv(self, name, value):
    self.vars[name] = value

  #----------------------------------------------------------------------------
  def exec_(self, expr, context=[]):
    if not is_list(expr): return [expr]

    args = list(expr)
    name = call = args.pop(0)
    opname = operator.get(call)
    if opname:
      call = re.sub(r'-', '_', 'exec_' + opname)
      return_ = getattr(self, call)(*args)

    else:
      args = list(map(
        (lambda x: self.exec_(x)[0] if is_list(x) else x),
        list(args)))

      context_ = list(context)
      context_.reverse()
      for item in context_:
        args.insert(0, item)

      if re.search(r'^[a-z]', call):
        call = re.sub(r'-', '_', call)
        method = getattr(self.bridge, call)
        if not method:
          die("Can't find bridge function: '%s'" % name)
        return_ = method(*args)

      elif re.search(r'^[A-Z]', call):
        call = call.lower()
        method = getattr(self.stdlib, call)
        if not method:
          die("Can't find TestML Standard Library function: '%s'" % name)
        return_ = method(*args)

      else:
        die("Can't resolve TestML function '%s'" % name)

    return [] if return_ is None else [return_]

  def exec_call(self, *args):
    context = []

    for call in args:
      context = self.exec_(call, context)

    if len(context): return context[0]

  def exec_eq(self, left, right, label_expr=''):
    got = self.exec_(left)[0]

    want = self.exec_(right)[0]

    label = self.get_label(label_expr)

    self.test_eq(got, want, label)

  def exec_func(self, signature, *statements):
    for statement in statements:
      self.exec_(statement)

  def exec_get_string(self, string):
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

  def exec_pickloop(self, list_, expr):
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

  def exec_point(self, name):
    return self.getp(name)

  def exec_set_var(self, name, expr):
    self.vars[name] = self.exec_(expr)[0]

  #----------------------------------------------------------------------------
  def initialize(self):
    self.code.insert(0, [])
    self.code.insert(0, '=>')

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
