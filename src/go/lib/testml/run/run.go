package run

import (
  "fmt"

  "encoding/json"
  "io/ioutil"
  "reflect"
  "regexp"
  "strings"

  "testml/bridge"
  "testml/stdlib"
u "testml/util"
)

type any = interface{}
type s2a = map[string]any
type s2s = map[string]string

type Tester interface {
  Testml_begin()
  Testml_end()
  Testml_eq(any, any, string)
}

type Run struct {
  file    string
  version string
  code    any
  data    any
  vars    s2a
  block   any
  error   any
  test    any
  tester  Tester
  bridge  any
  stdlib  any
  types   s2s
}

func (self *Run) dispatch(
  opcode string,
  args ...any,
) (ok bool, res any, err error) { u.Trace(opcode, args)
  ok = true
  switch opcode {
    case "==":  self.assert_eq(args[0], args[1], args[2:]...)
    case "~~":  self.assert_has(args[0], args[1], args[2:]...)
    case "=~":  self.assert_like(args[0], args[1], args[2:]...)
    case ".":   res = self.exec_dot(args...)
    case "%":   self.each_exec(args[0].([]any), args[1])
    case "%<>": self.each_pick(args[0].([]any), args[1].([]any))
    case "<>":  self.pick_exec(args[0].([]any), args[1])
    case "&":   self.call_func(args[0])
    case "\"":  self.get_str(args[0].(string))
    case ":":   self.get_hash(args[0], args[1].(string))
    case "[]":  self.get_list(args[0].([]any), args[1].(int))
    case "*":   res = self.get_point(args[0].(string))
    case "=":   self.set_var(args[0].(string), args[1])
    case "||=": self.or_set_var(args[0].(string), args[1])
    default:    ok = false
  }
  return
}

var types = s2s{
  "=>": "function",
  "/": "regex",
  "!": "error",
  "?": "native",
}

//-----------------------------------------------------------------------------
func New(
  file string,
  tester Tester,
) *Run { u.Trace(file, tester)

  self := new(Run)
  self.bridge = bridge.New()
  self.stdlib = stdlib.New(self)
  self.file = file
  self.tester = tester
  self.types = types
  self.vars = make(s2a)

  return self
}

func (self *Run) From_file(file string) { u.Trace(file)
  var testml s2a

  json_text, err := ioutil.ReadFile(file)
  if err != nil { panic(err) }

  u.Say(string(json_text))

  err = json.Unmarshal([]byte(json_text), &testml)
  if err != nil { panic(err) }

  self.code = testml["code"]
  self.data = testml["data"]
  self.version = testml["testml"].(string)
}

func (self *Run) Test() { u.Trace()
  self.tester.Testml_begin()

  for _, statement := range self.code.([]any) {
    self.exec_expr(statement, nil)
  }

  self.tester.Testml_end()
}

//-----------------------------------------------------------------------------
func (self *Run) exec(expr any) any { u.Trace(expr)
  return self.exec_expr(expr, nil).([]any)[0]
}

func (self *Run) exec_expr(
  expr any,
  context []any,
) any { u.Trace(expr, context)

  if self.Type(expr) != "expr" { return []any{expr} }

  args := make([]any, len(expr.([]any)))
  copy(args, expr.([]any))

  name := args[0].(string)
  opcode := name
  args = args[1:]

  var ok bool
  var ret any
  var err error

  if ok, ret, err = self.dispatch(opcode, args...); ok {
    // opcode dispatched; expr execed
  } else {
    list := make([]any, len(context))
    copy(list, context)
    for _, arg := range args {
      list = append(list, arg)
    }
    args = list

    if value, ok := self.vars[name]; ok {
      if len(args) > 0 {
        if self.Type(value) != "func" {
          panic("variable name has args but is not a function")
        }
        ret = self.exec_func([]any{value, args})
      } else {
        ret = value
      }

    } else if regexp.MustCompile("^[a-z]").MatchString(name) {
      ret, err = self.call_bridge(name, args)

    } else if regexp.MustCompile("^[A-Z]").MatchString(name) {
      ret, err = self.call_stdlib(name, args)

    } else {
      panic(fmt.Sprintf("Can't resolve TestML function '%s'", name))
    }
  }

  if err != nil { panic(err) }

  if ret == nil {
    return []any{}
  } else {
    return []any{ret}
  }
}

func (self *Run) exec_func(args ...any) any { u.Trace(args)
  fmt.Println("exec_func", args)
  panic("TODO exec_func")
}

//-----------------------------------------------------------------------------
func (self *Run) call_stdlib(
  name string,
  args []any,
) (ret any, err error) { u.Trace(name, args)

  call := strings.Title(replace(name, `-`, "_"))

  for i, expr := range args {
    args[i] = self.uncook(self.exec(expr))
  }

  ret, err = call_method(self.stdlib, call, args)

  ret = self.cook(ret)

  return
}

func (self *Run) call_bridge(
  name string,
  args []any,
) (ret any, err error) { u.Trace(name, args)

  call := strings.Title(replace(name, `-`, "_"))

  for i, expr := range args {
    args[i] = self.uncook(self.exec(expr))
  }

  ret, err = call_method(self.bridge, call, args)

  ret = self.cook(ret)

  return
}

//-----------------------------------------------------------------------------
func (self *Run) assert_eq(left any, right any, labels ...any) { u.Trace(left, right, labels)
  got := self.exec(left)
  want := self.exec(right)
  label := ""
  if len(labels) == 1 {
    label = labels[0].(string)
  }

  // XXX this is a hack. need to handle this properly.
  if reflect.ValueOf(want).Kind() == reflect.Float64 {
    want = int(want.(float64))
  }

  tgot := self.Type(got)
  twant := self.Type(want)
  switch tgot + "," + twant {
    case "num,num": self.assert_num_eq_num(got, want, label)
    case "str,str": self.assert_str_eq_str(got, want, label)
    default:
      panic(fmt.Sprintf("Method 'assert_%s_eq_%s' does not exist", tgot, twant))
  }
}

func (self *Run) assert_str_eq_str(
  got any,
  want any,
  label string,
) { u.Trace(got, want, label)

  self.tester.Testml_eq(got, want, self.get_label(label))
}

func (self *Run) assert_num_eq_num(
  got any,
  want any,
  label string,
) { u.Trace(got, want, label)

  self.tester.Testml_eq(got, want, self.get_label(label))
}

func (self *Run) assert_has(left any, right any, labels ...any) { u.Trace(left, right, labels)
  panic("TODO assert_has")
}

func (self *Run) assert_like(left any, right any, labels ...any) { u.Trace(left, right, labels)
  panic("TODO assert_like")
}

//-----------------------------------------------------------------------------
func (self *Run) exec_dot(calls ...any) any { u.Trace(calls)
  context := []any{}

  self.error = nil

  for _, call := range calls {
    context = self.exec_expr(call, context).([]any)
  }

  return context[0].(any)
}

func (self *Run) each_exec(list []any, expr any) { u.Trace(list, expr)
  panic("TODO Each_exec")
}

func (self *Run) each_pick(list []any, expr []any) { u.Trace(list, expr)
  for _, block := range self.data.([]any) {
    self.block = block

//     if block.point.ONLY and not @warned_only
//       @err "Warning: TestML 'ONLY' in use."
//       @warned_only = true

    self.exec_expr([]any{"<>", list, expr}, nil)
  }

  self.block = nil
}

func (self *Run) pick_exec(list[]any, expr any) { u.Trace(list, expr)
  pick := true

  for _, p := range list {
    point := p.(string)

   if match(point, `^\*`) {
      if _, ok := self.block.(s2a)["point"].(s2a)[point[1:]]; !ok {
        pick = false
        break
      }
    } else if match(point, `^\!\*`) {
      if _, ok := self.block.(s2a)["point"].(s2a)[point[2:]]; ok {
        pick = false
        break
      }
    }
  }

  if pick {
    if self.Type(expr) == "func" {
      self.exec_func(expr)
    } else {
      self.exec_expr(expr, nil)
    }
  }
}

func (self *Run) call_func(func_ any) { u.Trace(func_)
  panic("TODO Call_func")
}

func (self *Run) get_str(string_ string) { u.Trace(string_)
  panic("TODO get_str")
}

func (self *Run) get_hash(hash any, key string) { u.Trace(hash, key)
  panic("TODO get_hash")
}

func (self *Run) get_list(list []any, index int) { u.Trace()
  panic("TODO get_list")
}

func (self *Run) get_point(name string) any { u.Trace(name)
  return self.getp(name)
}

func (self *Run) set_var(name string, expr any) { u.Trace()
  if self.Type(expr) == "func" {
    self.setv(name, expr)
  } else {
    self.setv(name, self.exec(expr))
  }
}

func (self *Run) or_set_var(name string, expr any) { u.Trace()
  panic("TODO or_set_var")
}

//-----------------------------------------------------------------------------
func (self *Run) getp(name string) any { u.Trace(name)
  return self.block.(s2a)["point"].(s2a)[name]
}

func (self *Run) getv(name string) { u.Trace()
  panic("TODO getv")
}

func (self *Run) setv(name string, value any) { u.Trace()
  self.vars[name] = value
}

//-----------------------------------------------------------------------------
func (self *Run) Type(expr any) string { u.Trace(expr)
  if expr == nil { return "null" }

  switch reflect.ValueOf(expr).Kind() {
    case reflect.Slice:
      if len(expr.([]any)) == 0 { return "none" }
      switch reflect.ValueOf(expr.([]any)[0]).Kind() {
        case reflect.Map: return "hash"
        case reflect.Slice, reflect.Array: return "list"
        default: return "expr"
      }
    case reflect.Map:    return "hash"
    case reflect.String: return "str"
    case reflect.Bool:   return "bool"
    case reflect.Int, reflect.Uint,
         reflect.Int8, reflect.Uint8,
         reflect.Int16, reflect.Uint16,
         reflect.Int32, reflect.Uint32, reflect.Float32,
         reflect.Int64, reflect.Uint64, reflect.Float64, reflect.Complex64,
         reflect.Complex128: return "num"
    default: return "error"
  }
}

func (self *Run) cook(value any) any { u.Trace(value)
  return value
}

func (self *Run) uncook(value any) any { u.Trace(value)
  return value
}

//-----------------------------------------------------------------------------
func (self *Run) get_label(label_expr string) string { u.Trace(label_expr)
  label := self.exec(label_expr).(string)

  var ok bool
  if label == "" {
    if label, ok = self.vars["Label"].(string); !ok {
      label = ""
    }
  }

  var block_label string
  if self.block != nil {
    block_label = self.block.(s2a)["label"].(string)
  } else {
    block_label = ""
  }

  if label != "" {
    label = replace(label, `^\+`, block_label)
    label = replace(label, `\+$`, block_label)
    label = replace(label, `\{\+\}`, block_label)
  } else {
    label = block_label
  }

  return self.interpolate(label, true)
}

func (self *Run) interpolate(string_ string, label bool) string { u.Trace(string_, label)
  string_ = replacef(string_, `\{([\-\w]+)\}`,
    func(name string) string { return self.transform2(name, label) })
  string_ = replacef(string_, `\{\*([\-\w]+)\}`,
    func(name string) string { return self.transform2(name, label) })
  return string_
}

func (self *Run) transform(value any, label bool) string { u.Trace(value, label)
  if t := self.Type(value); t == "list" || t == "hash" {
    j, err := json.Marshal(value)
    if (err != nil) { panic(err) }
    return string(j)
  }
  res := fmt.Sprintf("%v", value)
  if label {
    res = replace(res, `\n`, "␤")
  }
  return res
}

func (self *Run) transform1(name string, label bool) string { u.Trace(name, label)
  var value any
  var ok bool
  name = replace(name, `.*([\-\w]+).*`, "$1")
  if value, ok = self.vars[name]; !ok {
    return ""
  }
  return self.transform(value, label)
}

func (self *Run) transform2(name string, label bool) string { u.Trace(name, label)
  var value any
  var ok bool
  if self.block != nil {
    name = replace(name, `.*([\-\w]+).*`, "$1")
    if value, ok = self.block.(s2a)["point"].(s2a)[name]; !ok {
      return ""
    }
  }
  return self.transform(value, label)
}

//-----------------------------------------------------------------------------
// Helper functions
//-----------------------------------------------------------------------------
func match(str string, rgx string) bool {
  return regexp.MustCompile(rgx).MatchString(str)
}

func replace(str string, rgx string, repl string) string {
  return regexp.MustCompile(rgx).ReplaceAllString(str, repl)
}

func replacef(str string, rgx string, repl func(string) string) string {
  return regexp.MustCompile(rgx).ReplaceAllStringFunc(str, repl)
}

func call_method(
  object any,
  name string,
  args []any,
) (ret any, err error) { u.Trace(name, args)

  method := reflect.ValueOf(object).MethodByName(name)

  if !method.IsValid() {
    panic(fmt.Sprintf("Method not found '%s'", name))
  }

  slice := false
  for i, arg := range args {
    if slice { continue }
    switch kind := method.Type().In(i).Kind(); kind {
      case reflect.Int: args[i] = int(arg.(float64))
      case reflect.String: args[i] = arg.(string)
      case reflect.Slice: slice = true
      default: panic(fmt.Sprintf("Unexpected kind of arg '%v'", kind))
    }
  }

  var res []reflect.Value
  if len(args) == 0 {
    res = method.Call(nil)
  } else {
    vargs := make([]reflect.Value, len(args))
    for i, arg := range args {
      vargs[i] = reflect.ValueOf(arg)
    }

    res = method.Call(vargs)
  }

  if len(res) == 1 {
    ret = res[0].Interface()
  } else if len(res) > 1 {
    ret = res
  }

  return
}
