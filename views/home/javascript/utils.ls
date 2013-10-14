{Obj,map, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'

exports = exports or this
# node: any node in the tree
# func: folding function :: (Node, Acc) -> Acc
# seed :: Acc
exports.fold-real-nodes = (node, func, seed) ->
	| node.children.length == 0 => func(node, seed)
	| otherwise => 
		fold ((ac, a) -> fold-real-nodes(a, func, ac)), seed, node.children


