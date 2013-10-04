{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'
request = require 'request'

hard-clone = -> JSON.parse JSON.stringify it

# hard-clones its input, but removes children property from it
# returns a tuple, (the original input, and new hard-cloned one)
hard-clone-without-children = ->
	cs = it.children; delete it.children; me = hard-clone(it); me.children = []; it.children = cs;
	[it, me]


reduce-tree = (method, property, node) ->
	| node.children.length == 0 => (find (->it.method == method), node.stats)[property]
	| otherwise => fold1 (+), flatten [reduce-tree(method, property, c) for c in node.children]



treefy = do -> (raw) ->

	# every node might be a parent
	data = map ((r) -> r.children = []; r), hard-clone(raw) # create a hard-clone of the input, becasue the following logic will modify the data
 
	root = {children: [], device: 'root'}

	# utility function that creates an empty stats object
	empty-stats = (method) -> {method: method, visits: 0, subscribers: 0}

	empty-device-os = (os) -> {os: os}
	empty-device-brand = (brand) -> {brand: brand}

	# add all the methods to every record.stats
	methods = unique flatten (map (-> [m.method for m in it.stats]), data)
	method-stats-or-empty = (method, stats) -> ((find (-> it.method == method), stats) or empty-stats(method))

	data = map (-> it.stats = [method-stats-or-empty(m, it.stats) for m in methods]; it), data

	# make the tree
	(map (-> 
		# hard-clones its input, but removes children property from it
		[parent,me] = hard-clone-without-children(it)
		parent.children.push(me)
		parent.stats = [empty-stats m for m in methods]
		parent)) 
		<| filter (-> it.children.length>0)
		<| map (-> ((find ((d) -> d.device == it.fall_back), data) or root).children.push(it); it) <| (data)

	# if a node is parent, then it's stats property must be the reduced sum of its children
	collect-stats = (node) ->
		| node.children.length == 0 => node.stats
		| otherwise => 
			r = [{method: m, visits: reduce-tree(m, 'visits', node), subscribers: reduce-tree(m, 'subscribers', node)} for m in methods]
			map (-> it.stats = collect-stats(it)), node.children	
			r
			
	# emptyMaker :: (GroupName, FirstItemInGroup) -> Device
	# propSelector :: Device -> String
	group-by-prop = (emptyMaker, propSelector, children) --> 
		(map (-> a = emptyMaker(it[0], it[1][0]); a.children = it[1]; a) <| obj-to-pairs <| group-by propSelector, children)
	
	group-by-brand = (children) -> group-by-prop empty-device-brand, (-> it.brand), children
	group-by-os = (children) -> group-by-prop empty-device-os, (-> it.os), children


	root.children = group-by-os root.children
	root.children = map (-> it.children = group-by-brand(it.children); it), root.children

	root.stats = collect-stats(root) # root is always a parent
	root

exports.treefy = treefy

