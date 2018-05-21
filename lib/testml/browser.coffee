_global = window.global
_require = window.require
_module = window.module

window.global = window
window.require = -> require: ->
window.module = {}

```
# include npm/lib/testml/index.js
# include npm/lib/testml/run.js
# include npm/lib/testml/tap.js
# include npm/lib/testml/run/tap.js
# include npm/lib/testml/run/mocha.js
# include npm/lib/testml/bridge.js
# include npm/lib/testml/stdlib.js
```

TestML.browser = true

window.global = _global
window.require = _require
window.module = _module
