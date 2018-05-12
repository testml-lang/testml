#! bash

# shellcheck disable=1090,2034,2154
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
p,print     Print compiled TestML to stdout
l,list      List all the TestML langauge/framework runners
env         Show the TestML environment details
clean       Remove generated TestML files
version     Print TestML version
h,help      Show the command summary
 
R,run=      TestML runner to use (see: testml --list)
M,module=   TestML runner module to use
I,lib=      Directory path to find TestML modules
P,path=     Directory path to find TestML test files
C,config=   TestML config file
 
x,debug     Print lots of debugging info
"

source "$TESTML_ROOT/bin/getopt.sh"

testml-run-cli() {
  get-options "$@"

  set -- "${arguments[@]}"

  "cmd-$cmd" "$@"
}

cmd-run() {
  for file; do
    check-input-file "$file"

    set-testml-bin

    set-input-vars

    compile-testml

    if [[ -z $testml_runner_sourced ]]; then
      testml_runner_sourced=true
      source "$TESTML_BIN"
    fi

    testml-run-file "$TESTML_EXEC_PATH" || true
  done
}

cmd-compile() {
  for file; do
    check-input-file "$file"

    set-input-vars


    if $option_print; then
      testml-compiler "$TESTML_INPUT_PATH"

    else
      mkdir -p "$TESTML_CACHE"

      testml-compiler "$TESTML_INPUT_PATH" > "$TESTML_EXEC_PATH" || {
        rc=$?
        rm -f "$TESTML_EXEC_PATH"
        exit $rc
      }
    fi
  done
}

cmd-list() {
  cat <<...
TestML runners use a programming language with one of its testing frameworks.

TestML supports the following runners:

    coffee-mocha    CoffeeScript with Mocha
    coffee-tap      CoffeeScript with TAP
    node-mocha      NodeJS with Mocha
    node-tap        NodeJS with TAP
    perl-tap        Perl 5 with TAP (Test::Builder)
    perl6-tap       Perl 6 with TAP (Test::Builder)
    python-pytest   Python 2 with Pytest

Aliases:
    coffee          Alias for coffee-mocha
    node            Alias for node-mocha
    perl            Alias for perl-tap
    perl6           Alias for perl-tap
    python          Alias for python-pytest

...
}

cmd-env() {
  if [[ -n $1 ]]; then
    export TESTML_INPUT=$1
    set-input-vars
  fi

  env | grep '^TESTML_'
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
  GETOPT_ARGS='@arguments' \
    getopt "$@"

  $option_debug && set -x

  if $option_clean; then
    make-clean

    [[ ${#arguments[@]} -gt 0 ]] || exit 1
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

  [[ -n $option_run ]] &&
    export TESTML_RUN="$option_run"

  true
}
