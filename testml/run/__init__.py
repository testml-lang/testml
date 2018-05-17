import json, os, re, sys

from testml.util import *

operator = {
  '=='    : 'eq',
  '.'     : 'call',
  '=>'    : 'func',
  "$''"   : 'get-string',
  '%()'   : 'pickloop',
  '*'     : 'point',
}

class TestMLRun:
  def __init__(self, testml=None, bridge=None):
    self.testml = testml
    self.bridge = bridge

  def from_file(self, testml_file):
    self.testml_file = testml_file

    self.testml = json.loads(open(testml_file).read())

    return self

  def test(self):
    self.initialize()

    self.test_begin()

    self.exec_(self.code)

    self.test_end()

  def initialize(self):
    self.code = self.testml['code']

    self.code.insert(0, [])
    self.code.insert(0, '=>')

    self.data = list(map(
      (lambda x: TestMLBlock(x)),
      self.testml['data']))

    if not self.bridge:
      sys.path.insert(0, os.environ['TESTML_INPUT_DIR'])

      bridge_module = __import__(os.environ['TESTML_BRIDGE'])

      self.bridge = (bridge_module.TestMLBridge)()

  def exec_(self, expr, context=[]):
    # print 'exec)', expr, 'context(%s)' % context
    if not is_list(expr):
      return [expr]

    args = list(expr)
    call = args.pop(0)
    name = operator.get(call)
    if name:
      call = 'exec_' + name
      call = re.sub(r'-', '_', call)
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
          die("Can't find bridge function: '%s'" % call)
        return_ = method(*args)

      elif re.search(r'^[A-Z]', call):
        call = call.lower()
        method = getattr(self.stdlib, call)
        if not method:
          die("Can't find TestML Standard Library function: '%s'" % call)
        return_ = method(*args)

      else:
        die("Can't resolve TestML function '%s'" % call)

    # print 'after)', expr, ' => ', [] if return_ is None else [return_]

    return [] if return_ is None else [return_]

  def exec_call(self, *args):
    context = []

    for call in args:
      # print 'call)', call, 'context(%s)' % context
      context = self.exec_(call, context)
      # print 'context)', context

    if len(context):
      return context[0]

    return

  def exec_eq(self, left, right, label=''):
    got = self.exec_(left)[0]

    want = self.exec_(right)[0]

    label = self.get_label(label)

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
        if re.match(r'\*', point):
          if not block.point.get(point[1:]):
            pick = False
            break

        elif re.match(r'\!\*', point):
          if block.point.get(point[2:]):
            pick = False
            break

      if pick:
        self.block = block
        self.exec_(expr)

    self.block = None

  def exec_point(self, name):
    return self.block.point[name]

  #----------------------------------------------------------------------------
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

class TestMLBlock:
  def __init__(self, obj):
    self.label = obj['label']
    self.point = obj['point']
