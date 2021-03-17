# -*- coding: utf8 -*-

from __future__ import print_function
import json, os, re, sys

from testml.util import *
from testml.util import basestring

class TestMLFunction():
  def __init__(self, func):
    self.func = func
class TestMLNull(): pass
class TestMLNil(): pass

class TestMLRun:
  Nil = TestMLNil()
  Null = TestMLNull()

  vtable = {
    '==' : 'assert_eq',
    '~~' : 'assert_has',
    '=~' : 'assert_like',

    '.'  : 'exec_dot',
    '%'  : 'each_exec',
    '%<>': 'each_pick',
    '<>' : 'pick_exec',
    '&'  : 'call_func',

    '"'  : 'get_str',
    ':'  : 'get_hash',
    '[]' : 'get_list',
    '*'  : 'get_point',

    '='  : 'set_var',
    '||=': 'or_set_var',
  }

  types = {
    'str': 'str',
    'unicode': 'str',
    'int': 'num',
    'float': 'num',
    'bool': 'bool',
    '=>': 'func',
    '/': 'regex',
    '!': 'error',
    '?': 'native',
    'groups': {
      'list': 'list',
      'dict': 'hash',
    },
  }

  #----------------------------------------------------------------------------
  def __init__(self, **params):
    self.file = params.get('file')
    self.ast = params.get('testml', {})

    self.bridge = params.get('bridge')
    self.stdlib = params.get('stdlib')

    self.vars = {}
    self.block = None
    self.warned_only = False
    self.error = None
    self.thrown = None

  def from_file(self, file_):
    self.file = file_

    if file_ == '-':
      self.ast = json.loads(sys.stdin.readlines())
    else:
      self.ast = json.loads(open(file_).read())

    return self

  def test(self):
    self.testml_begin()

    for statement in self.ast.get('code', []):
      self.exec_expr(statement)

    self.testml_end()

  #----------------------------------------------------------------------------
  def exec_(self, expr):
    return self.exec_expr(expr)[0]

  def exec_expr(self, expr, context=[]):
    if self.type_(expr) != 'expr':
      return [expr]

    args = list(expr)

    opcode = name = args.pop(0)
    call = self.vtable.get(opcode)
    if call:
      if is_list(call):
        call = call[0]
      ret = getattr(self, call)(*args)

    else:
      context_ = list(context)
      context_.reverse()
      for item in context_:
        args.insert(0, item)

      value = self.vars.get(name)
      if value is not None:
        if len(args):
          if self.type_(value) != 'func':
            die("Variable value has args but is not a function")
          ret = self.exec_func(value, args)
        else:
          ret = value

      elif re.search(r'^[a-z]', name):
        ret = self.call_bridge(name, args)

      elif re.search(r'^[A-Z]', name):
        ret = self.call_stdlib(name, args)

      else:
        die("Can't resolve TestML function '%s'" % name)

    return [] if ret is self.Nil else [ret]

  def exec_func(self, func, args=[]):
    signature = func[1]
    statements = func[2]

    if len(signature) > 1 and len(args) == 1 and self.type_(args) == 'list':
      args = args[0]

    if len(signature) != len(args):
      die("TestML function expected '%d' arguments, but was called with '%d' arguments" % (len(signature), len(args)))

    i = 0
    for v in signature:
      self.vars[v] = self.exec_(args[i])
      i += 1

    for statement in statements:
      self.exec_expr(statement)

  #----------------------------------------------------------------------------
  def make_class(self, code):
    exec(code)
    return eval('TestMLBridge')

  def call_bridge(self, name, args):
    if not self.bridge:
      code = self.ast.get('bridge', {}).get('python', None)
      if code:
        self.bridge = (self.make_class(
          'class TestMLBridge():\n' + \
            re.sub(r'^', '  ', code, 0, re.M)
        ))()
      else:
        bridge_module = __import__(os.environ['TESTML_BRIDGE'])
        self.bridge = (bridge_module.TestMLBridge)()

    call = getattr(self.bridge, re.sub(r'-', '_', name))
    if not call:
      die("Can't find bridge function: '%s'" % name)

    args = list(map(
      (lambda x: self.uncook(self.exec_(x))),
      list(args)))

    ret = call(*args)

    if ret is None: return self.Nil

    return self.cook(ret)

  def call_stdlib(self, name, args):
    if not self.stdlib:
      from testml.stdlib import StdLib
      self.stdlib = StdLib(self)

    call = getattr(self.stdlib, name.lower())
    if not call:
      die("Unknown TestML Standard Library function: '%s'" % name)

    args = list(map(
      (lambda x: self.uncook(self.exec_(x))),
      list(args)))

    ret = call(*args)

    if ret is None: return self.Nil

    return self.cook(ret)

  #----------------------------------------------------------------------------
  def assert_eq(self, left, right, label=''):
    self.vars['Got'] = got = self.exec_(left)
    self.vars['Want'] = want = self.exec_(right)
    method = self.get_method('assert_%s_eq_%s', got, want)
    getattr(self, method)(got, want, label)

  def assert_str_eq_str(self, got, want, label):
    self.testml_eq(got, want, self.get_label(label))

  def assert_num_eq_num(self, got, want, label):
    self.testml_eq(got, want, self.get_label(label))

  def assert_bool_eq_bool(self, got, want, label):
    self.testml_eq(got, want, self.get_label(label))


  def assert_has(self, left, right, label=''):
    got = self.exec_(left)
    want = self.exec_(right)
    method = self.get_method('assert_%s_has_%s', got, want)
    getattr(self, method)(got, want, label)

  def assert_str_has_str(self, got, want, label):
    self.vars['Got'] = got
    self.vars['Want'] = want
    self.testml_has(got, want, self.get_label(label))

  def assert_str_has_list(self, got, want, label):
    for str in want[0]:
      self.assert_str_has_str(got, str, label)

  def assert_list_has_str(self, got, want, label):
    self.vars['Got'] = got
    self.vars['Want'] = want
    self.testml_list_has(got[0], want, self.get_label(label))

  def assert_list_has_list(self, got, want, label):
    for str in want[0]:
      self.assert_list_has_str(got, str, label)


  def assert_like(self, left, right, label=''):
    got = self.exec_(left)
    want = self.exec_(right)
    method = self.get_method('assert_%s_like_%s', got, want)
    getattr(self, method)(got, want, label)

  def assert_str_like_regex(self, got, want, label):
    self.vars['Got'] = got
    self.vars['Want'] = "/%s/" % want[1]
    self.testml_like(got, want[1], self.get_label(label))

  def assert_str_like_list(self, got, want, label):
    for regex in want[0]:
      self.assert_str_like_regex(got, regex, label)

  def assert_list_like_regex(self, got, want, label):
    for str_ in got[0]:
      self.assert_str_like_regex(str_, want, label)

  def assert_list_like_list(self, got, want, label):
    for str_ in got[0]:
      for regex in want[0]:
        self.assert_str_like_regex(str_, regex, label)

  #----------------------------------------------------------------------------
  def exec_dot(self, *calls):
    context = []

    self.error = None
    for call in calls:
      if self.error is None:
        try:
          if self.type_(call) == 'func':
            self.exec_func(call, context[0])
            context = []
          else:
            context = self.exec_expr(call, context)
        except Exception as e:
          self.error = self.call_stdlib('Error', [str(e)])
      else:
        if call[0] == 'Catch':
          context = [self.error]
          self.error = None

    if self.error:
      raise Exception('Uncaught Error: ' + self.error[1].msg)

    if len(context): return context[0]

  def each_exec(self, list_, expr):
    list_ = self.exec_(list_)
    expr = self.exec_(expr)

    for item in list_[0]:
      self.vars['_'] = [item]
      if self.type_(expr) == 'func':
        if len(expr[1]) == 0:
          self.exec_func(expr)
        else:
          self.exec_func(expr, [item])
      else:
        self.exec_func(expr)

  def each_pick(self, list_, expr):
    for block in self.ast.get('data', []):
      self.block = block

      if block.get('ONLY') and not self.warned_only:
        self.err("Warning: TestML 'ONLY' in use.")
        self.warned_only = True

      self.exec_expr(['<>', list_, expr])

    self.block = None

  def pick_exec(self, list_, expr):
    pick = True
    for point in list_:
      if (re.match(r'\*', point) and
          self.block.get(point[1:])) == None or \
         (re.match(r'\!\*', point) and
          self.block.get(point[2:])):
        pick = False
        break

    if pick:
      if self.type_(expr) == 'func':
        self.exec_func(expr)
      else:
        self.exec_expr(expr)

  def call_func(self, func):
    func = self.exec_(func)
    if func is None or self.type_(func) != 'func':
      die("Tried to call '%s' but is not a function" % name)
    self.exec_func(func)

  def get_str(self, string):
    return self.interpolate(string)

  def get_hash(self, hash_, key):
    hash_ = self.exec_(hash_)
    key = self.exec_(key)
    type_ = self.type_(hash_)

    if type_ == 'hash': return self.cook(hash_[0].get(key))
    if type_ == 'error':
      if key != 'msg':
        die("Invalid Error property '%s'" % key)
      return self.cook(hash_[1].msg)
    else:
      die("Can't lookup hash key on value of type '%s'" % type_)

  def get_list(self, list_, index):
    list_ = self.exec_(list_)
    try:
      value = list_[0][index]
    except:
      value = self.Nil

    return self.cook(value)

  def get_point(self, name):
    return self.getp(name)

  def set_var(self, name, expr):
    if self.type_(expr) == 'func':
      self.setv(name, expr)
    else:
      self.setv(name, self.exec_(expr))

  def or_set_var(self, name, expr):
    if self.vars.get(name) is not None: return

    if self.type_(expr) == 'func':
      self.setv(name, expr)
    else:
      self.setv(name, self.exec_(expr))
    return

  #----------------------------------------------------------------------------
  def getp(self, name):
    if not self.block:
      return
    value = self.block.get(name)
    if value is not None:
      value = self.exec_(value)
    return value

  def getv(self, name):
    return self.vars.get(name)

  def setv(self, name, value):
    self.vars[name] = value

  #----------------------------------------------------------------------------
  def type_(self, value):
    if value is None:
      return 'null'

    type_ = type(value).__name__
    if self.types.get(type_):
      return self.types.get(type_)
    if type_ == 'list':
      if len(value) == 0:
        return 'none'
      if isinstance(value[0], basestring):
        return self.types.get(value[0]) or 'expr'
      else:
        type_ = self.types['groups'].get(type(value[0]).__name__)
        if type_:
          return type_

    die("Can't get type of '%s'" % repr(value))

  def cook(self, value):
    if value is self.Null or value is None:
      return None
    if value is self.Nil:
      return []
    type_ = type(value).__name__
    if re.search(r'^(unicode|str|int|float|bool)$', type_): return value
    if re.search(r'^(list|dict)$', type_): return [value]
    if type_ == 'SRE_Pattern' or type_ == 'Pattern': return ['/', value]
    if value.__class__.__name__ == 'TestMLError': return ['!', value]
    if value.__class__.__name__ == 'TestMLFunction': return value.func
    return ['?', value]

  def uncook(self, value):
    type_ = self.type_(value)
    if re.search(r'^(str|num|bool|null)$', type_): return value
    if re.search(r'^(list|hash)$', type_): return value[0]
    if re.search(r'^(error|native)$', type_): return value[1]
    if type_ == 'func': return TestMLFunction(value)
    if type_ == 'regex':
      if isinstance(value[1], basestring): return re.compile(value[1])
      else: return value[1]
    if type_ == 'none': return self.Nil
    die("Can't uncook '%s'" % repr(value))

  #----------------------------------------------------------------------------
  def get_method(self, pattern, *args):
    method = pattern % (self.type_(args[0]), self.type_(args[1]))

    if not getattr(self, method):
      die("Method '%(method)s' does not exist" % locals())

    return method

  def get_label(self, label_expr=''):
    label = self.exec_(label_expr)

    if not label:
      label = self.getv('Label')
      if not label:
        label = ''

    block_label = self.block['Label'] if self.block else ''
    if block_label is None:
        block_label = ''

    if label:
      label = re.sub(r'^\+', block_label, label)
      label = re.sub(r'\+$', block_label, label)
      label = re.sub(r'\{\+\}', block_label, label)
    else:
      label = block_label

    return self.interpolate(label, True)

  def interpolate(self, string, label=False):
    string = re.sub(
        r'\{([\-\w]+)\}', (lambda m: self.transform1(m, label)), string)
    string = re.sub(
        r'\{\*([\-\w]+)\}', (lambda m: self.transform2(m, label)), string)

    return string

  def transform(self, value, label):
    if label:
      if re.search(r'^(?:list|hash)$', self.type_(value)):
        return repr(value[0])
      else:
        return re.sub(r'\n', u'␤', str(value))
    else:
      if re.search(r'^(?:list|hash)$', self.type_(value)):
        return repr(value[0])
      else:
        return str(value)

  def transform1(self, m, label):
    value = self.vars.get(m.group(1))
    return self.transform(value, label) if value != None else ''

  def transform2(self, m, label):
    if not self.block: return ''
    value = self.block.get(m.group(1))
    return self.transform(value, label) if value != None else ''

  def err(self, msg):
    print(msg, file=sys.stderr)

# vim: sw=2:
