_global = window.global
window.global = window

_require = window.require
window.require = -> require: ->

_exports = window.exports
window.exports = {}

```
# include node_modules/pegex/lib/pegex/index.js
# include node_modules/pegex/lib/pegex/grammar.js
# include node_modules/pegex/lib/pegex/receiver.js
# include node_modules/pegex/lib/pegex/tree.js
# include node_modules/pegex/lib/pegex/input.js
# include node_modules/pegex/lib/pegex/optimizer.js
# include node_modules/pegex/lib/pegex/parser.js
# include npm/lib/testml-compiler/index.js
# include npm/lib/testml-compiler/grammar.js
# include npm/lib/testml-compiler/ast.js
# include npm/lib/testml-compiler/compiler.js
```

TestMLCompiler.browser = true

window.global = _global
window.require = _require
window.exports = _exports
