### Command Line

Once installed, you should have access to the `testml` command, which can run test, and compile `.tml` files. The `testml --help` output is:
```
usage:   testml <options...> [<testml-file>...]

    See 'man testml' for more help.

    Common commands:

      testml foo.tml
      testml --lang=python foo.tml
      testml --compile foo.tml
      testml --compile --print foo.tml
      testml --list
      testml --env
      testml --clean

    Options:

    -c, --compile         Compile a TestML file to the cache directory
    -e, --eval ...        Specify TestML input on command line
    -i, --input ...       Main input file (prepended to each file arg)
    -a, --all             Combine all input files into one text
    -p, --print           Print compiled TestML to stdout
    -l, --list            List all the TestML langauge/framework runners
    --env                 Show the TestML environment details
    --clean               Remove generated TestML files
    --version             Print TestML version
    -h, --help            Show the command summary

    -R, --run ...         TestML runner to use (see: testml --list)
    -B, --bridge ...      TestML bridge module to use
    -I, --lib ...         Directory path to find bridge modules
    -P, --path ...        Directory path to find test files and imports
    -M, --module ...      TestML runner module to use
    -C, --config ...      TestML config file

    -x, --debug           Print lots of debugging info
```

#### Examples:

*   `testml -R python test/*.tml`
*   `testml -cp test/*.tml`
