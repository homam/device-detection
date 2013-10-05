prelude = require('prelude-ls')
{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'

pow = Math.pow
sqrt = Math.sqrt


# utility functions 

trace = (v) ->
	console.log v
	v

# methodSelector :: Method -> Bool
# prop :: String
_sum-stats = (methodSelector, prop, node) --> fold1 (+) <| ([m[prop] for m in node.stats when methodSelector(m.method)])
sum-visits = (methodSelector, node) --> 	_sum-stats methodSelector, 'visits', node
sum-subscribers = (methodSelector, node) --> _sum-stats methodSelector, 'subscribers', node

# node: any node in the tree
# func: folding function :: (Node, Acc) -> Acc
# seed :: Acc
fold-real-nodes = (node, func, seed) ->
	| node.children.length == 0 => func(node, seed)
	| otherwise => 
		fold ((ac, a) -> fold-real-nodes(a, func, ac)), seed, node.children

# update all nodes with accumulated stats info
update-all-nodes = (updater, node) -->
	| node.children.length == 0 => node
	| otherwise => (map (update-all-nodes updater), node.children)
	updater node

# remove children with low number of visits
# visitsSelector: Node -> Number
kill-children = (minVisits, visitsSelector, node) -->
	| node.children.length == 0 => node
	| otherwise => 
		node.children = filter (-> visitsSelector(it) > minVisits), node.children
		(map (kill-children minVisits, visitsSelector), node.children)
	node


# (String -> Bool), Node -> [Visits, Subscribers, Conversion]
stats = (methodFilter, node) ->
	v = sum-visits methodFilter, node
	s = sum-subscribers methodFilter, node
	c = if v == 0 then 0 else s/v
	[v,s,c]





width = 1000
height = 2000
tree = d3.layout.tree().size([height, width - 160]);

diagonal = d3.svg.diagonal().projection((d) -> [d.y, d.x])

svg = d3.select("body").append("svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(40,0)")

root <- $.get '/data/ae.json'

#allSubscriptionMethods = [m.method for m in root.stats]

allSubscriptionMethodsAndTheirLabels = 
	[["GooglePlay", 'G'], ["WAP", 'DW'], ["sms", 'sms'], ["Unknown", 'U'], ["SMS_WAP", 'MO'], ["JAVA_APP", 'J'], [null, 'NA'], ["WAPPIN", 'P']]


# selected methods region

selectedSubscriptionMethods = ['sms', 'smsto', 'mailto', 'JAVA_APP'] #GooglePlay

# [String] -> (String -> Bool)
create-method-filter = (selectedMethods) -> (method) -> method in selectedMethods

# String -> Bool
selected-method-filter = create-method-filter selectedSubscriptionMethods

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


console.log convAverageSelected
console.log convAverageSelected
console.log convStnDevSelected

# end selected methods region

root = kill-children 100, selected-visits, root


sor = (a,b) -> if (!!a and a.length > 0 and a != ' ') then a else b

color = d3.scale.quantile().range ['#f21b1b', '#ed771c', '#e9ce1e', '#a9e41f', '#53df21', '#22da40', '#23d58e', '#24cbd0', '#257ecb', '#2636c7']

color.domain([0, convAverageSelected+2*convStnDevSelected])

nodes = tree.nodes(root)
links = tree.links(nodes)
link = svg.selectAll("path.link").data(links).enter().append("path").attr("class", "link").attr("d", diagonal)
node = svg.selectAll("g.node").data(nodes).enter().append("g").attr("class", "node")
	.attr("transform", (d) -> "translate(#{d.y},#{d.x})")
node.append("circle").attr("r", 4.5)
node.append("text").attr("dx", (d) -> (if d.children.length > 0 then -8 else 8))
	.attr("dy", 3).attr("text-anchor", (d) -> (if d.children.length > 0 then "end" else "start"))
	.text((d) -> 
		name  = (d.device `sor` d.brand `sor` d.os `sor` '')
		# dStats :: [Method, Code, Visits, Subscribers, Conversion]
		dStats = [[m,l] ++ stats(create-method-filter([m]), d) for [m, l] in allSubscriptionMethodsAndTheirLabels]
		dMethodsWithVisits = fold ((acc, c) -> if c[2] > 0 then acc ++ c[1] else acc), [], dStats 
		name + ' {' + (join '|', dMethodsWithVisits) + '}'
	)
	.attr('fill', -> color selected-stats(it)[2])
	.on('mousedown', -> onMouseOver it)


onMouseOver = (node) ->
	vTotal = sum-visits (->true), node
	[vSelected, sSelected, cSelected]  = selected-stats node
	#console.log vTotal, vSelected, cSelected, convAverageSelected
	#console.log <| stats (->true), node
	console.log selected-stats node
