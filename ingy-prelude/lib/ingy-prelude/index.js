// Generated by CoffeeScript 2.3.1
(function() {
  // Ingy döt Net's Prelude for NodeJS programming:
  require('lodash').extend(global, {
    IngyPrelude: {
      VERSION: '0.0.2'
    },
    // Use lodash
    _: require('lodash'),
    // Use most common builtin modules:
    fs: require('fs'),
    path: require('path'),
    // Common I/O and termination functions:
    out: function(string) {
      return process.stdout.write(String(string));
    },
    err: function(string) {
      return process.stderr.write(String(string));
    },
    say: function(...string) {
      return out(`${string.join(' ')}\n`);
    },
    warn: function(...string) {
      return err(`${string.join(' ')}\n`);
    },
    exit: function(rc = 0) {
      return process.exit(rc);
    },
    die: function(msg) {
      err(`Died: ${msg}\n`);
      return exit(1);
    },
    // Synchronous disk I/O functions:
    file_read: function(file_path) {
      if (file_path === '-') {
        return fs.readFileSync('/dev/stdin').toString();
      } else {
        return fs.readFileSync(file_path).toString();
      }
    },
    file_write: function(file_path, output) {
      if (file_path === '-') {
        return fs.writeFileSync('/dev/stdout', output);
      } else {
        return fs.writeFileSync(file_path, output);
      }
    },
    file_exists: function(file_path) {
      return fs.existsSync(file_path);
    },
    // Debugging functions:
    dump: function(...data) {
      var dump, elem, i, len, util;
      util = require('util');
      dump = '';
      for (i = 0, len = data.length; i < len; i++) {
        elem = data[i];
        dump += util.inspect(elem) + '\n...\n';
      }
      return dump;
    },
    jjj: function(...data) {
      var elem, i, len;
      for (i = 0, len = data.length; i < len; i++) {
        elem = data[i];
        say(JSON.stringify(elem, null, 2));
      }
      say('...');
      return data[0];
    },
    www: function(...data) {
      err(dump(...data));
      return data[0];
    },
    xxx: function(...data) {
      err(dump(...data));
      return exit(1);
    },
    yyy: function(...data) {
      out(dump(...data));
      return data[0];
    },
    DUMP: function(...data) {
      var dump, elem, i, len, yaml;
      yaml = require('js-yaml');
      dump = '';
      for (i = 0, len = data.length; i < len; i++) {
        elem = data[i];
        dump += `---\n${yaml.dump(elem)}...\n`;
      }
      return dump;
    },
    WWW: function(...data) {
      err(DUMP(...data));
      return data[0];
    },
    XXX: function(...data) {
      err(DUMP(...data));
      return exit(1);
    },
    YYY: function(...data) {
      out(DUMP(...data));
      return data[0];
    }
  });

}).call(this);