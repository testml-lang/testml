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

  dump: (data...)->
    util = require 'util'
    dump = ''
    for elem in data
      dump += util.inspect(elem) + '\n...\n'
    dump
  xxx: (data...)->
    err dump data...
    exit 1
  yyy: (data...)->
    out dump data...
    data[0]
  www: (data...)->
    err dump data...
    data[0]
  jjj: (data...)->
    for elem in data
      say JSON.stringify elem, null, 2
    say '...'
    data[0]
  DUMP: (data...)->
    yaml = require 'js-yaml'
    dump = ''
    for elem in data
      dump += "---\n#{yaml.dump elem}...\n"
    dump
  XXX: (data...)->
    err DUMP data...
    exit 1
  yyy: (data...)->
    out dump data...
    data[0]
  WWW: (data...)->
    err DUMP data...
    data[0]

  read_file: (file_path)->
    if file_path == '-'
      fs.readFileSync('/dev/stdin').toString()
    else
      fs.readFileSync(file_path).toString()
  write_file: (file_path, output)->
    if file_path == '-'
      fs.writeFileSync('/dev/stdout', output)
    else
      fs.writeFileSync(file_path, output)
  file_exists: (file_path)->
    fs.existsSync file_path
