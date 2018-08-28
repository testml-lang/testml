package main

import "fmt"
import "os"
import "encoding/json"
import "reflect"
import "io/ioutil"

type Run struct {
  browser bool
  env     map[string]string
  types   map[string]string
  file    string
  version string
  code    interface{}
  data    string
  vtable  map[string]interface{} //*Vtable
}

func NewVtable() map[string]interface{} {
  x := make(map[string]interface{})
  x["=="] = [2]interface{}{"assert_eq", make(map[string]interface{})}
  eq := x["=="].([2]interface{})[1].(map[string]interface{})
  eq["assert-%1-eq-%2"] = make(map[string]string)
  eq["assert-%1-eq-%2"].(map[string]string)["str,str"] = ""
  eq["assert-%1-eq-%2"].(map[string]string)["num,num"] = ""
  eq["assert-%1-eq-%2"].(map[string]string)["bool,bool"] = ""

  x["~~"] =  [2]interface{}{"assert_has", make(map[string]interface{})}
  til := x["~~"].([2]interface{})[1].(map[string]interface{})
  til["assert-%1-has-%2"] = make(map[string]string)
  til["assert-%1-has-%2"].(map[string]string)["str,str"] = ""
  til["assert-%1-has-%2"].(map[string]string)["str,list"] = ""
  til["assert-%1-has-%2"].(map[string]string)["list,str"] = ""
  til["assert-%1-has-%2"].(map[string]string)["list,list"] = ""


  x["=~"] =  [2]interface{}{"assert_like", make(map[string]interface{})}
  eqt := x["=~"].([2]interface{})[1].(map[string]interface{})
  eqt["assert-%2-like-%2"] = make(map[string]string)
  eqt["assert-%2-like-%2"].(map[string]string)["str,str"] = ""
  eqt["assert-%2-like-%2"].(map[string]string)["str,regex"] = ""
  eqt["assert-%2-like-%2"].(map[string]string)["str,list"] = ""
  eqt["assert-%2-like-%2"].(map[string]string)["list,regex"] = ""
  eqt["assert-%2-like-%2"].(map[string]string)["list,list"] = ""

  x["."] = "exec_dot"
  x["%"] = "each_exec"
  x["%<>"] = "each_pick"
  x["<>"] = "pick_exec"
  x["&"] = "call_func"
  x["\""] = "get_str"
  x[":"] = "get_hash"
  x["[]"] = "get_list"
  x["*"] = "get_point"
  x["="] = "set_var"
  x["||="] = "or_set_var"

  return x
}

func NewRun(file string, testml map[string]string ) *Run {
  x := new(Run)
  x.env = make(map[string]string)
  x.types = make(map[string]string)
  x.vtable = NewVtable()

  x.env["TESTML_DEVEL"] = "1"
  x.types["=>"] = "function"
  x.types["/"] = "regex"
  x.types["!"] = "error"
  x.types["?"] = "native"

  x.file = file

  if _, ok := testml["version"]; ok {
    x.version = testml["version"]
  }
  if _, ok := testml["code"]; ok {
    x.code = testml["code"]
  }
  if _, ok := testml["data"]; ok {
    x.data = testml["data"]
  }
  return x
}

func (r *Run) from_file(file string) {
  var result map[string]interface{}
  slurpd, err := ioutil.ReadFile(file)
  if err != nil {
    fmt.Println("Error: ", err)
    os.Exit(1)
  }
  err = json.Unmarshal([]byte(slurpd), &result)
  if _, ok := result["code"].([]interface{}); ok {
    r.code = result["code"].([]interface{})
  }
  if _, ok := result["data"].(string); ok {
    r.data = result["data"].(string)
  }
  if ver, ok := result["testml"].(string); ok {
    r.version = ver
  }
}

func (r *Run) test() {
  //r.test_begin()
  for _, value := range r.code.([]interface{}) {
    r.exec_expr(value, nil)
  }
  //r.test_end();
}

func (r *Run) exec(expr []string) {
  r.exec_expr(expr[0], nil)
}

func indirect_func(runner interface{}, func_name string, params ...interface{}) (out []reflect.Value, err error) {
	class_val := reflect.ValueOf(runner)
	meth := class_val.MethodByName(func_name)
  fmt.Println(meth)
	if !meth.IsValid() {
			return make([]reflect.Value, 0), fmt.Errorf("Method not found \"%s\"", func_name)
	}
	in := make([]reflect.Value, len(params))
	for i, param := range params {
			in[i] = reflect.ValueOf(param)
	}
	out = meth.Call(in)
	return
}

func (r *Run) exec_expr(expr interface{}, ctx []interface{}) {
  expr_type := r.cmp_type(expr)
  if expr_type != "expr" {
    //return []interface{ expr }
  }
  expr_copy := expr.([]interface{})
  name, expr_copy := expr_copy[0], expr_copy[1:]
  opcode := name
  call := r.vtable[opcode.(string)]
  if call != nil {
    switch reflect.TypeOf(call).Kind() {
      case reflect.Slice, reflect.Array: call = call.([]interface{})[0]
    }
		_, err := indirect_func(r, call.(string), expr_copy)
		fmt.Println(err)
  }

  fmt.Println(expr, name, expr_type, opcode, call)
}

func (r *Run) each_pick (args []interface{}) {
	fmt.Println(args)
}

func (r *Run) cmp_type (expr interface{}) string {
  if expr == nil {
    return "null"
  }
  tcheck := reflect.TypeOf(expr).Kind()
  switch tcheck {
    case reflect.Slice, reflect.Array:
      if len(expr.([]interface{})) == 0 { return "none" }
      subcheck := reflect.TypeOf(expr.([]interface{})[0]).Kind()
      if subcheck == reflect.Map { return "hash" }
      if subcheck == reflect.Slice || subcheck == reflect.Array { return "list" }
      return "expr"
    case reflect.Map: return "hash"
    case reflect.String: return "string"
    case reflect.Bool: return "bool"
    case     reflect.Uint8,     reflect.Uint16, reflect.Uint32, reflect.Uint64,
              reflect.Int8,      reflect.Int16, reflect.Int32,  reflect.Int64,
           reflect.Float32,    reflect.Float64,
         reflect.Complex64, reflect.Complex128:
      return "num"
  }
  return "error"
}

func main() {
  x := NewRun("", map[string]string{"version":"0"})
  x.from_file("../../../../test/runtime-tml/.testml/010-math.tml.json")
  x.test()
}
