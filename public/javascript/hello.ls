require.config({
  baseUrl: ''
  map:
    '*':
      'css': 'javascript/libs/require-css/css'
      'text': 'javascript/libs/require-text'
})

fun <- require(['javascript/fun'])

console.log fun

console.log "hello!"