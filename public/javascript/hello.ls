
require.config({
  baseUrl: ''
  map:
    '*':
      'css': 'javascript/libs/require-css/css'
      'text': 'javascript/libs/require-text'
})

window.requirejs = require

console.log 'before loading fun'

fun <- require(['javascript/fun'])

console.log fun.fuck()

console.log "hello!"