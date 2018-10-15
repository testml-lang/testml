package stdlib

import(
u "testml/util"
)

type any = interface{}

type Run interface {
  Type(any) string
}

type StdLib struct {
  run Run
}

func New(run Run) *StdLib { u.Trace(run)
    self := new(StdLib)
    self.run = run
    return self
}

func (self *StdLib) Cat(strings ...string) string { u.Trace(strings)
  cat := ""
  for _, str := range strings {
    cat += str
  }
  return cat
}

func (self *StdLib) Type(value any) string { u.Trace(value)
  return self.run.Type(value)
}

func (self *StdLib) True() bool { u.Trace()
  return true
}
