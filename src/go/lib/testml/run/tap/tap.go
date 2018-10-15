package tap

import (
  "fmt"

  "testml/run"
u "testml/util"
)

type any = interface{}

type Tap struct {
  count int
  checked bool
  planned bool
}

func Run(file string) { u.Trace(file)
  self := New(file)
  self.From_file(file)
  self.Test()
}

func New(file string) *run.Run { u.Trace(file)
  return run.New(
    file,
    &Tap{
      count: 0,
      checked: false,
      planned: false,
    },
  )
}

func (self *Tap) Testml_begin() { u.Trace()
}

func (self *Tap) Testml_end() { u.Trace()
  if ! self.planned {
    self.tap_done()
  }
}

func (self *Tap) Testml_eq(
  got any,
  want any,
  label string,
) { u.Trace(got, want, label)

  self.tap_is(got, want, label)
}

func (self *Tap) tap_pass(label string) { u.Trace(label)
  self.count = self.count + 1
  fmt.Printf("ok %d - %s\n", self.count, label)
}

func (self *Tap) tap_fail(label string) { u.Trace(label)
  self.count = self.count + 1
  fmt.Printf("not ok %d - %s\n", self.count, label)
}

func (self *Tap) tap_is(
  got any,
  want any,
  label string,
) { u.Trace(got, want, label)

  if got == want {
    self.tap_pass(label)
  } else {
    self.tap_fail(label)
  }
}

func (self *Tap) tap_done() { u.Trace()
  fmt.Printf("1..%d\n", self.count)
}
