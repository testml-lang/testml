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
  testml --env
  testml --clean

Options:
--
 
c,compile   Compile a TestML file
e,eval=     Specify TestML input on command line
p,print     Print compiled TestML to stdout
env         Show the TestML environment details
clean       Remove generated TestML files
version     Print TestML version
h,help      Show the command summary
 
f,config=   TestML config file
l,lang=     Programming language to use
b,bin=      TestML language command to use (eg 'testml-perl')
R,run=      TestML runtime module to use
I,lib=      Directory path to find TestML modules
B,bridge=   TestML bridge module to use
P,path=     Directory path to find bridge modules
 
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

    [[ -n $TESTML_LANG_SOURCED ]] ||
      source "$TESTML_BIN"

    testml-run-file "$TESTML_EXEC_PATH" || true
  done
}

cmd-compile() {
  for file; do
    check-input-file "$file"

    set-input-vars

    if $option_print; then
      testml-compiler "$TESTML_INPUT_PATH" || true

    else
      testml-compiler "$TESTML_INPUT_PATH" > "$TESTML_EXEC_PATH" || {
        rm -f "$TESTML_EXEC_PATH"
      }
    fi
  done
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
  elif $option_version; then
    cmd=version
  elif $option_compile; then
    cmd=compile
  else
    cmd=run
  fi

  [[ -n $option_lang ]] &&
    export TESTML_LANG="$option_lang"

  true
}
