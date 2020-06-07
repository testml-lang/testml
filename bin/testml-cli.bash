# echo ">>> Entering bin/testml-cli.bash
# \$0 = $0
# \$BASH_SOURCE = $BASH_SOURCE
# \$TESTML_SOURCED = ${TESTML_SOURCED-}
# -t 0 = $([[ -t 0 ]] && echo yes || echo no)
# -t 1 = $([[ -t 1 ]] && echo yes || echo no)
# <<<
# " >&2

# die DEAD

# shellcheck disable=1090,2034,2153,2154

set -e -u -o pipefail

GETOPT_SPEC="\
  $(basename "$0") <options...> [<testml-file>...]

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
--
 
c,compile   Compile a TestML file to the cache directory
e,eval=     Specify TestML input on command line
i,input=    Main input file (prepended to each file arg)
a,all       Combine all input files into one text
p,print     Print compiled TestML to stdout
l,list      List all the TestML langauge/framework runners
env         Show the TestML environment details
clean       Remove generated TestML files
version     Print TestML version
h,help      Show the command summary
 
R,run=      TestML runner to use (see: testml --list)
B,bridge=   TestML bridge module to use
I,lib=      Directory path to find bridge modules
P,path=     Directory path to find test files and imports
M,module=   TestML runner module to use
C,config=   TestML config file
 
x,debug     Print lots of debugging info
"

source "$TESTML_ROOT/bin/getopt.bash"

testml-run-cli() {
  get-options "$@"

  set -- "${arguments[@]}"

  "cmd-$cmd" "$@"
}

cmd-run() {
  for file; do
    check-input-file "$file"

    add-eval-text

    set-testml-vars

    set-testml-bin

    compile-testml

    if [[ -z ${testml_runner_sourced-} ]]; then
      source "$TESTML_BIN"
    fi

    set-testml-lib-vars

    testml-run-file "$TESTML_AST"
  done
}

cmd-compile() {
  for file; do
    check-input-file "$file"

    add-eval-text

    set-testml-vars

    if $option_print; then
      TESTML_AST=''
    fi

    compile-testml "$TESTML_FILE" "$TESTML_AST"
  done
}

cmd-list() {
  less -FRX <<...
TestML programs are meant to be run against any programming language along with
any existing test framework. To run a TestML test you need to specify which
'runner' (aka 'runtime') to use.

You can specify which runner to use with the -R/--run command option, or the
extended command name or the TESTML_RUN variable. Like this:

    testml -R python-unit my-test.tml
    testml --run=python-unit my-test.tml
    testml-python-unit my-test.tml
    TESTML_RUN=python-unit my-test.tml

If the TestML test is only ever meant to run against one runner, then you can
name the runner in the test file's shebang line:

    #!/usr/bin/env testml-python-unit

and then simply run it like:

    testml my-test.tml

or if the TestML file is executable, like this:

    ./my-test.tml

TestML supports the following runners:

    bash-tap        Bash language, with the TAP test framework
    coffee-mocha    CoffeeScript w/ Mocha
    coffee-tap      CoffeeScript w/ TAP
    go-tap          Go w/ TAP
    node-mocha      NodeJS w/ Mocha
    node-tap        NodeJS w/ TAP
    perl-tap        Perl w/ TAP
    python-tap      Python (2 or 3) w/ TAP
    python-tap      Python (2 or 3) w/ unittest
    raku-tap        Raku w/ TAP

Aliases:
    coffee          Alias for coffee-mocha
    node            Alias for node-mocha
    perl            Alias for perl-tap
    python          Alias for python-unit
    raku            Alias for raku-tap

NOTE: For shebang line usage with Perl use 'testml-pl' instead of
'testml-perl'.

...
}

cmd-env() {
  [[ $1 ]] ||
    die "usage: testml --env <testml-file>"

  export TESTML_INPUT=$1

  set-testml-vars
  set-testml-lib-vars

  env | grep '^TESTML_' | sort
}

make-clean() {
  # We can't really find the CACHE directory without a filename, so for now we
  # just delete all .testml directories under us in a repo.

  # TODO Check for non-git repos
  git rev-parse --is-inside-work-tree &>/dev/null ||
    die "Can only use --clean inside a code repository"

  for dir in $(find . -type d | grep '/\.testml$'); do
    (
      set -x
      rm -fr "$dir"
    )
  done
}

cmd-version() {
  echo "TestML v$TESTML_VERSION"
}

get-options() {
  local option_eval_lines=1
  GETOPT_ARGS='@arguments' \
    getopt "$@"

  setup-eval

  $option_debug && set -x

  if $option_clean; then
    make-clean

    [[ ${#arguments[@]} -gt 0 ]] || exit 1
  fi

  if [[ ${option_config-} ]]; then
    export TESTML_CONFIG=$option_config
  fi

  if [[ ${option_bridge-} ]]; then
    export TESTML_BRIDGE=$option_bridge
  fi
  if [[ ${option_lib-} ]]; then
    TESTML_LIB=$(cd "$option_lib" && pwd)
    export TESTML_LIB
  fi
  if [[ ${option_path-} ]]; then
    TESTML_PATH=$(cd "$option_path" && pwd)
    export TESTML_PATH
  fi

  if $option_env; then
    cmd='env'
  elif $option_list; then
    cmd='list'
  elif $option_version; then
    cmd=version
  elif $option_compile; then
    cmd=compile
  else
    cmd=run
  fi

  [[ ${option_run-} ]] &&
    export TESTML_RUN=$option_run

  true
}

setup-eval() {
  testml_eval_input=''

  if [[ ${option_eval+x} ]]; then
    for line in "${option_eval[@]}"; do
      testml_eval_input+=$line$'\n'
    done
  fi

  if [[ ${option_input-} ]]; then
    testml_eval_input+=$(cat "$option_input")$'\n'
  fi

  if $option_all; then
    [[ ${arguments+x} && ${#arguments[@]} -gt 0 ]] ||
      die "--all used but no input files specified"
    for file in "${arguments[@]}"; do
      testml_eval_input=$testml_eval_input$(cat "$file")$'\n'
    done
    arguments=('-')
  else
    testml_eval_text=$testml_eval_input
  fi

  [[ ${arguments+x} && ${#arguments[@]} -gt 0 ]] ||
    arguments=('-')
}

add-eval-text() {
  [[ ${testml_eval_text-} ]] || return 0

  testml_eval_input=$testml_eval_text
  if [[ $file != '-' ]]; then
    testml_eval_input+=$(cat "$file")$'\n'
  fi

  file='-'

  export TESTML_FILEVAR=$TESTML_INPUT
  export TESTML_INPUT='-'
}

# vim: ft=sh sw=2 lisp:
