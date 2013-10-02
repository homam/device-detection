
requirejs = this.requirejs or require('requirejs')
requirejs.config({nodeRequire: require})
(require, exports, module) <- define() 


exports.fuck =  -> 'fuck!'

exports.suck = ->
	console.log 'fun fun!'

exports