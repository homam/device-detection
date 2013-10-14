prelude = require('prelude-ls')
{Obj,map, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique,sort-by, maximum, minimum} = require 'prelude-ls'

pow = Math.pow
sqrt = Math.sqrt
floor = Math.floor
round = Math.round

# utility functions 

format-date = d3.time.format('%Y-%m-%d')

hard-clone = -> JSON.parse JSON.stringify it

trace = (v) ->
	console.log v
	v

sor = (a,b) -> if (!!a and a.length > 0 and a != ' ') then a else b

name-node = (n) -> n.device `sor` n.brand `sor` n.os `sor` ''


shorten-wurfl-device-name = (name) ->
	if !name 
		return name
	verIndex = name.indexOf("ver")
	return if verIndex > 0 then name.substr(0, verIndex+1) + '..' else name

# methodSelector :: Method -> Bool
# prop :: String
_sum-stats = (methodSelector, prop, node) --> fold1 (+) <| ([m[prop] for m in node.stats when methodSelector(m.method)])
sum-visits = (methodSelector, node) --> 	_sum-stats methodSelector, 'visits', node
sum-subscribers = (methodSelector, node) --> _sum-stats methodSelector, 'subscribers', node


# update all nodes with accumulated stats info
update-all-nodes = (updater, node) -->
	| node.children.length == 0 => node
	| otherwise => (map (update-all-nodes updater), node.children)
	updater node


# remove children that match the criteria
# criteria: Node -> Bool
kill-children-by-criteria = (criteria, node) -->
	| node.children.length == 0 => node
	| otherwise => 
		node.children = filter (-> criteria it), node.children
		(map (kill-children-by-criteria criteria), node.children)
	node

# remove children with low number of visits
# visitsSelector: Node -> Number
kill-children = (minVisits, visitsSelector, node) --> 
	kill-children-by-criteria (-> visitsSelector(it) > minVisits), node


# (String -> Bool), Node -> [Visits, Subscribers, Conversion]
stats = (methodFilter, node) ->
	v = sum-visits methodFilter, node
	s = sum-subscribers methodFilter, node
	c = if v == 0 then 0 else s/v
	[v,s,c]




exports = exports or this

exports.devices-histogram = (width = 1000, height = 1000) ->
	height = 600
	width= 1000

	bins = 20
	margins = [20, 50, 50, 20]
	x = d3.scale.ordinal().rangeRoundBands([0, width - margins[1] - margins[3]]).domain([0 to bins-1])
	y = d3.scale.linear().range([0, height - margins[0] - margins[2]])	
	$svg = d3.select(".tree").append("svg")
	.attr("class", "devices-histogram")
	.attr("width", width).attr("height", height).append("g").attr("transform", "translate(#{margins[3]},#{height - margins[2]})")

	# root :: Node
	# selectedSubscriptionMethods :: [String]
	# selectedSubscriptionMethodsOr :: Bool
	# call this function to update the UI and the tree graphics
	update-tree = (root, selectedSubscriptionMethods, selectedSubscriptionMethodsOr, excludeDesktop, killChildrenThreshold = 100) ->

		if excludeDesktop
			root.children = filter (-> it.os != 'Desktop'), root.children

		# [String] -> (String -> Bool)
		create-method-filter = (selectedMethods) -> (method) -> method in selectedMethods

		# all if selectedSubscriptionMethods is null
		# String -> Bool
		selected-method-filter = if !selectedSubscriptionMethods then (->true) else create-method-filter selectedSubscriptionMethods

		# Node -> Number
		selected-visits = sum-visits selected-method-filter

		# Node -> Number
		selected-subscribers = sum-subscribers selected-method-filter

		# Node -> [Visits, Subscribers, Conv]
		selected-stats = (node) -> stats selected-method-filter, node


		[totalVisitsSelected,totalSubscribersSelected,convAverageSelected] = selected-stats root

		convStnDevSelected = fold-real-nodes root, ((n, acc) -> 
			[v,s,conv] = selected-stats n
			acc + sqrt(pow(conv - convAverageSelected, 2))*v/totalVisitsSelected), 0


		#console.log convAverageSelected
		#console.log convAverageSelected
		#console.log convStnDevSelected

		# utility for animating transition
		transition = (node) -> node.transition().duration(500)

		# end selected methods region

		if selectedSubscriptionMethodsOr
			root = kill-children killChildrenThreshold, selected-visits, root # or
		else
			root = kill-children-by-criteria ((node) ->
				all (->it), [((find (-> it.method == m), node.stats).visits > killChildrenThreshold) for m in selectedSubscriptionMethods]
			), root # and




		# convert the tree to an array
		untree = do -> map (-> it.selectedStats = selectedStats(it); it) <| filter (-> !!it and !!it.stats) <|
			fold-real-nodes root, ((n, acc) -> [n] ++ acc), null

		convMax = (maximum <| map (-> it.selectedStats[2]) <| untree)
		convMin = 0
		binSize = convMax/(bins-1)

		

		make-y0 = ->
			last = 0
			(d) ->
				current = last
				last := d.y + last
				return current


		# blocks :: [ name, values :: [Node :: {x, y, y0, ...}] ]
		blocks = do ->
			((input) -> [{name: t.name, values: (map (->it.y0 = y0(it); it), t.values)} for [t, y0] in input]) <|
			# create new y0 makers for each block
			map (-> [it, make-y0()]) <|
			# sort the y values so the larger block will be at the bottom
			((input) -> [{name:parseInt(name), values:(sort-by (->-it.y), values)} for [name, values] in input]) <| 
			obj-to-pairs <| group-by (-> it.x) <|
			map (-> 
				it.x = (round <| it.selectedStats[2] / binSize);
				it.y = it.selectedStats[0];
				it) <| untree
		
		# fill the empty bins
		blocks = do -> 
			map ((b)->{name:b, values:((find (-> it.name == b), blocks) or {values:[]}).values}) <| [0 to bins-1]


		y.domain([0, do -> maximum <| map (-> it.y + it.y0) <| flatten <| map (-> it.values) <| blocks])


		$bin = $svg.selectAll('g.bin').data(blocks)
		$binEnter = $bin.enter().append('g').attr('class', 'bin')
		$bin.exit().remove()
		$bin.attr("transform", -> "translate(#{x(it.name)},#{margins[0]})")

		$binEnter.append('text').attr('class', 'bin-label')
		.attr("text-anchor", "middle").attr("dy", "1em")
		$bin.select('text.bin-label').attr("x", x.rangeBand() / 2).attr("y", 0).text(-> d3.format('.1%')(it.name * binSize))


		$device = $bin.selectAll('g.device').data(-> it.values)
		$deviceEnter = $device.enter().append('g').attr('class', 'device')
		.on('mousedown', -> $render-node-methods-stats it)
		$deviceEnter.append('rect')
		$device.select('rect').attr("width", -> x.rangeBand()).attr("height", -> y(it.y))
		.attr("x", 0).attr("y", -> -y(it.y0) - y(it.y))
		$device.exit().remove()
		





		# render stats in footer
		$render-node-methods-stats = (node) ->
			$(window).trigger("tree/node-selected", [node])

		#$render-node-methods-stats root






	# return
	{	
		$svg,
		update-tree
	}

