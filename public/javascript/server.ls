requirejs = require('requirejs')
requirejs.config({nodeRequire: require})

fun <- requirejs(['./fun'])

console.log fun.fuck()

console.log "hello!"