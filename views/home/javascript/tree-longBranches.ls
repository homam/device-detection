prelude = require('prelude-ls')
{Obj,map, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'

pow = Math.pow
sqrt = Math.sqrt

listOfSubscriptioMethods = [{"id":0,"name":"Unknown", label: "??"},{"id":11,"name":"WAP", label: "DW"},{"id":1,"name":"sms", label: "SMS"},{"id":2,"name":"smsto", label: "STO"},{"id":3,"name":"mailto", label: "MTO"},{"id":7,"name":"SMS_WAP", label: "MO"},{"id":8,"name":"LINKCLICK", label: "LKC"},{"id":6,"name":"JAVA_APP", label: "JA"},{"id":4,"name":"LinkAndPIN", label: "LnP"},{"id":5,"name":"LinkAndPrefilledPIN", label: "LnPP"},{"id":9,"name":"WAPPIN", label: "Pin"},{"id":10,"name":"GooglePlay", label: "GP"}]

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

exports.tree-long-branches = (width = 1000, height = 1000) ->
	tree = d3.layout.tree().size([height, width - 260]);

	diagonal = d3.svg.diagonal().projection((d) -> [d.y, d.x])

	$svg = d3.select(".tree").append("svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(40,0)")

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

		nodes = tree.nodes(root)
		links = tree.links(nodes)
		$link = $svg.selectAll("path.link").data(links) # select
		$link.enter().append("path").attr("class", "link").attr("d", diagonal({source: {x:0,y:0}, target: {x:0,y:0}})) #.attr("d", diagonal) # enter
		transition($link).attr("d", diagonal) # upadte

		$node = $svg.selectAll("g.node").data(nodes) #s select
		$nodeEnter = $node.enter().append("g").attr("class", "node") # enter
		transition($node).attr("transform", (d) -> "translate(#{d.y},#{d.x})") # update
		$nodeEnter.append("circle").attr("r", 4.5) # enter
		$nodeEnter.append("text") # select
		$node.select("text").attr("dx", (d) -> (if d.children.length > 0 then -8 else 8))
			.attr("dy", 3).attr("text-anchor", (d) -> (if d.children.length > 0 then "end" else "start"))
			.text((d) -> 
				name  = (d.device `sor` d.brand `sor` d.os `sor` '')
				# dStats :: [Method, Code, Visits, Subscribers, Conversion]
				dStats = [[m,l] ++ stats(create-method-filter([m]), d) for {name:m, label:l} in listOfSubscriptioMethods]
				dMethodsWithVisits = fold ((acc, c) -> if c[2] > 0 then acc ++ c[1] else acc), [], dStats 
				shorten-wurfl-device-name(name) + ' {' + (join '|', dMethodsWithVisits) + '}'
			)
			.attr('fill', -> color selected-stats(it)[2])
			.on('mousedown', -> $render-node-methods-stats it) # update

		$node.exit().remove() # exit
		$link.exit().remove() # exit


		# render stats in footer
		$render-node-methods-stats = (node) ->
			$(window).trigger("tree/node-selected", [node])

		$render-node-methods-stats root






	# return
	{	
		$svg,
		update-tree
	}

