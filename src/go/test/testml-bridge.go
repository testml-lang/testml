package bridge

import "os"

type Bridge struct { }

type Mine struct { }

func New() *Bridge {
  self := new(Bridge)
  return self
}

func (self *Bridge) Hash_lookup(
  hash map[string]interface{},
  key string,
) interface{} {

  return hash[key]
}

func (self *Bridge) Get_env(name string) string {
  return os.Getenv(name)
}

func (self *Bridge) Add(x, y int) int {
  return x + y
}

func (self *Bridge) Sub(x, y int) int {
  return x - y
}

func (self *Bridge) Cat(x, y string) string {
  return x + y
}

func (self *Bridge) Mine() *Mine {
  return new(Mine)
}
