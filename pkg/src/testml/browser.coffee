_global = window.global
_require = window.require
_module = window.module

window.global = window
window.require = -> require: ->
window.module = {}

```
# include lib/testml/index.js
# include lib/testml/run.js
# include lib/testml/run/tap.js
# include lib/testml/run/mocha.js
# include lib/testml/bridge.js
# include lib/testml/stdlib.js
```

TestML.browser = true

window.global = _global
window.require = _require
window.module = _module
