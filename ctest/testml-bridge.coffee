class TestMLBridge extends TestML.Bridge
  undent: (text)->
    text.replace /^    /mg, ''

  compile: (testml)->
    compiler = new TestMLCompiler.Compiler

    compiler.compile testml
