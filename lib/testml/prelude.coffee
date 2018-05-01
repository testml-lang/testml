lodash = require 'lodash'

lodash.extend global,
  _: lodash
  fs: require 'fs'
  path: require 'path'

  out: (string)->
    process.stdout.write String string
  err: (string)->
    process.stderr.write String string
  exit: (rc=0)->
    process.exit rc
  say: (string...)->
    out "#{string.join ' '}\n"
  warn: (string...)->
    err "#{string.join ' '}\n"
  die: (msg)->
    err "Died: #{msg}\n"
    exit 1

  xxx: (data...)->
    yyy data...
    exit 1
  yyy: (data...)->
    for elem in data
      console.dir elem
    say '...'
    data[0]
  jjj: (data...)->
    for elem in data
      say JSON.stringify elem, null, 2
    say '...'
    data[0]
  XXX: (data...)->
    YYY data...
    exit 1
  YYY: (data...)->
    yaml = require 'js-yaml'
    for elem in data
      out "---\n#{yaml.dump elem}"
    say '...'
    data[0]

  read_file: (file_path)->
    if file_path == '-'
      fs.readFileSync('/dev/stdin').toString()
    else
      fs.readFileSync(file_path).toString()
  file_exists: (file_path)->
    fs.existsSync file_path
