package main

import tap "testml/run/tap"
import "os"

func main() {
  tap.Run(os.Args[1])
}
