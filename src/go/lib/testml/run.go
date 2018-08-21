package main

import "fmt"
import "os"
import "encoding/json"
import "io/ioutil"
//import "reflect"

type Run struct {
  browser bool
  env     map[string]string
  types   map[string]string
  file    string
  version string
  code    interface{}
  data    interface{}
  vtable  map[string]interface{} //*Vtable
}

func NewVtable() map[string]interface{} {
  x := make(map[string]interface{})
  x["=="] =  [2]interface{}{"assert_eq", make(map[string]map[string]string)}
  eqmap := x["=="].([2]interface{})[1].(map[string]map[string]string)
  eqmap["assert-%1-eq-%2"] = make(map[string]string)
  eqmap["assert-%1-eq-%2"]["str,str"] = ""
  eqmap["assert-%1-eq-%2"]["num,num"] = ""
  eqmap["assert-%1-eq-%2"]["bool,bool"] = ""

  x["~~"] = [2]interface{}{"assert-has", make(map[string]map[string]string)}
  tilde := x["~~"].([2]interface{})[1].(map[string]map[string]string)
  tilde["assert-%1-has-%2"] = make(map[string]string)
  tilde["assert-%1-has-%2"]["str,str"] = ""
  tilde["assert-%1-has-%2"]["str,list"] = ""
  tilde["assert-%1-has-%2"]["list,str"] = ""
  tilde["assert-%1-has-%2"]["list,list"] = ""


  x["=~"] = [2]interface{}{"assert-like", make(map[string]map[string]string)}
  eqtil := x["=~"].([2]interface{})[1].(map[string]map[string]string)
  eqtil["assert-%1-like-%2"] = make(map[string]string)
  eqtil["assert-%1-like-%2"]["str,str"] = ""
  eqtil["assert-%1-like-%2"]["str,regex"] = ""
  eqtil["assert-%1-like-%2"]["str,list"] = ""
  eqtil["assert-%1-like-%2"]["list,regex"] = ""
  eqtil["assert-%1-like-%2"]["list,list"] = ""

  x["."] = "exec-dot"
  x["%"] = "each-exec"
  x["%<>"] = "each-pick"
  x["<>"] = "pick-exec"
  x["&"] = "call-func"
  x["\""] = "get-str"
  x[":"] = "get-hash"
  x["[]"] = "get-list"
  x["*"] = "get-point"
  x["="] = "set-var"
  x["||="] = "or-set-var"

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

func (r Run) exec() {
}

func (r *Run) from_file(file string) {
  var result map[string]interface{}
  slurpd, err := ioutil.ReadFile(file)
  if err != nil {
    fmt.Println("Error: ", err)
    os.Exit(1)
  }
  err = json.Unmarshal([]byte(slurpd), &result)
  if _, ok := result["code"]; ok {
    r.code = result["code"]//x
  }
  if _, ok := result["data"]; ok {
    r.data = result["data"]
  }
  if ver, ok := result["testml"].(string); ok {
    r.version = ver
  }
}

func (r *Run) test() {
  r.test_begin()
  if code, ok := r.code.([]interface{}); ok {
    fmt.Println("found code")
    for _, stmt := range code {
      r.exec_expr(stmt)
    }
  } else {
    fmt.Println("nok")
  }
}

func (r *Run) test_begin() {
  fmt.Println("test begin")
}

func (r *Run) exec_expr(stmt interface{}) {
  fmt.Println("stmt: ", stmt)
}

func main() {
  x := NewRun("", map[string]string{"version":"0"})
  x.from_file("../../../../test/runtime-tml/.testml/010-math.tml.json")
  x.test()
}
