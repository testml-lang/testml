$ ->
  $('button').click ->
    alert JSON.stringify global.exports.pegex('a: /(b)/').parse('b')
    # alert JSON.stringify global.exports.pegex('a: b').grammar.make_tree()
