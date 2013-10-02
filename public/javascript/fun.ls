exports = exports ? this

console.log 'inside fun'

exports.fuck = 'fuck!'

exports.fun = ->
	console.log 'fun fun!'