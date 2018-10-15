package util

import(
  "fmt"
  "os"
  "runtime"
  "strings"
  "reflect"

  "spew"
)

type any = interface{}

func debug() bool {
  return os.Getenv("TESTML_DEBUG") != "" ||
         os.Getenv("TESTML_DEVEL") != ""
}
func trace() bool {
  return os.Getenv("TESTML_TRACE") != "" ||
         os.Getenv("TESTML_DEVEL") != ""
}

func Die(args ...any) {
  fmt.Println(args...)
  os.Exit(1)
}

func Say(args ...any) {
  if debug() {
    Say_(args...)
  }
}

func Say_(args ...any) {
  fmt.Println(args...)
}

func Spew(args ...any) {
  if debug() {
    Spew_(args...)
  }
}

func Spew_(args ...any) {
  spew.Dump(args...)
}

func Trace(args ...any) {
  if trace() {
    Trace_(args...)
  }
}

func Trace_(args ...any) {
  a := make([]uintptr, 1)

  n := runtime.Callers(3, a)
  if n == 0 {
    fmt.Println("[TRACE] <TRACE error>")
    return
  }

  fun := runtime.FuncForPC(a[0] - 1)
  if fun == nil {
    fmt.Println("[TRACE] n/a")
    return
  }

  t := make([]any, 0)
  t = append(t, "[TRACE]")

  name := fun.Name()
  name = strings.Replace(name, "testml/run.(*Run).", "Run.", 1)
  name = strings.Replace(name, "testml/run/tap.(*Tap).", "Tap.", 1)
  name = strings.Replace(name, "testml/stdlib.(*StdLib).", "StdLib.", 1)
  name = strings.Replace(name, "testml/run.", "", 1)
  t = append(t, name)

  if len(args) > 0 {
    t = append(t, "(")
    for i := 0; i < len(args); i++ {
      if i > 0 {
        t = append(t, ",")
      }
      if i == 0 && reflect.ValueOf(args[i]).Kind() == reflect.Ptr {
        t = append(t, "@")
      } else {
        t = append(t, args[i])
      }
    }
    t = append(t, ")")
  } else {
    t = append(t, "...")
  }

  fmt.Println(t...)
}
