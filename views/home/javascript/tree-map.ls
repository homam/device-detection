prelude = require('prelude-ls')
{Obj,map, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'

pow = Math.pow
sqrt = Math.sqrt

# utility functions 

format-date = d3.time.format('%Y-%m-%d')

hard-clone = -> JSON.parse JSON.stringify it

trace = (v) ->
	console.log v
	v

sor = (a,b) -> if (!!a and a.length > 0 and a != ' ') then a else b


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

exports.tree-map = (width = 1000, height = 1000) ->

	$svg = d3.select(".tree").append("svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(-.5,-.5)")

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


		color = d3.scale.quantile().range ['#f21b1b', '#ed771c', '#e9ce1e', '#a9e41f', '#53df21', '#22da40', '#23d58e', '#24cbd0', '#257ecb', '#2636c7']
		color.domain([0, convAverageSelected+2*convStnDevSelected])

		

		# the actual d3 code region

		treemap = d3.layout.treemap().padding(0).size([width, height]).value(-> selected-stats(it)[0])

		$cell = $svg.data([root]).selectAll("g.cell").data(treemap.nodes)
		$cellEnter = $cell.enter().append("g").attr("class", "cell")
		transition($cell).attr("transform", (d) ->"translate(" + d.x + "," + d.y + ")")
		
		$cellEnter.append("rect").on('mousedown', -> $render-node-methods-stats it) # enter
		transition($cell.select('rect').attr('class', -> "node-#{it.treeId}")).attr("width", (d) -> d.dx).attr("height", (d) -> d.dy)
		.style("fill", -> if it.children and it.children.length > 0 then 'none' else color selected-stats(it)[2]) # update

		$cellEnter.append("text").on('mousedown', -> $render-node-methods-stats it) # enter
		$cell.select('text')
		# .attr("x", (d) ->d.dx / 2).attr("y", (d) ->d.dy / 2).attr("dy", ".35em").attr("text-anchor", "middle")
		# .text((d) ->(if d.children and d.children.length>0 then null else shorten-wurfl-device-name(d.device `sor` d.brand `sor` d.os `sor` '')))
		.attr('x', 0).attr('dx', "0.35em").attr('dy', "0.9em")
		.each((d) -> d.key = (if d.children and d.children.length>0 then null else shorten-wurfl-device-name(d.device `sor` d.brand `sor` d.os `sor` '')))
		.each(fontSize)
		.each(wordWrap)


		$cell.exit().remove()
		# end the actual d3 code region



		# render stats in footer
		$render-node-methods-stats = (node) ->
			$(window).trigger("tree/node-selected", [node])

		$render-node-methods-stats root






	# return
	{	
		$svg,
		update-tree
	}

