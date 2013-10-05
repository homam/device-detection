# utility functions 

sum-stats = (node, prop) -> fold1 (+) <| ([m[prop] for m in node.stats])
visits = (node) -> 	sum-stats node, 'visits'
subscribers = (node) -> sum-stats node, 'subscribers'

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
kill-children = (minVisits, node) -->
	| node.children.length == 0 => node
	| otherwise => 
		node.children = filter (-> it.visits > minVisits), node.children
		(map (kill-children minVisits), node.children)
	node




window.requirejs = require
prelude = require('prelude-ls')

map = prelude.map
flatten = prelude.flatten
group-by = prelude.group-by
obj-to-pairs = prelude.obj-to-pairs
fold1 = prelude.fold1
fold = prelude.fold
filter = prelude.filter
pow = Math.pow
sqrt = Math.sqrt

width = 1000
height = 2000
tree = d3.layout.tree().size([height, width - 160]);

diagonal = d3.svg.diagonal().projection((d) -> [d.y, d.x])

svg = d3.select("body").append("svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(40,0)")

root <- $.get '/data/ae.json'
#map (-> it.children = []) <| flatten <| map (-> it.children) <| map (-> console.log(it.length); it[0]) <| (map -> it.children) root.children


selectedSubscriptionMethods = ['sms', 'smsto', 'mailto', 'JAVA_APP'] #GooglePlay

stats-filter = (node) -> [m for m in node.stats when m.method in selectedSubscriptionMethods]

update-all-nodes ((node) -> 
	node.stats = stats-filter node
	node
	), root


update-all-nodes ((node) ->
	node.visits = visits node
	node.subscribers = subscribers node
	node.conv = node.subscribers/node.visits
	node), root


totalVisits = visits root
totalSubscribers = subscribers root
totalConv = totalSubscribers / totalVisits



root = kill-children 0, root

convStnDev = fold-real-nodes root, ((n, acc) -> acc + sqrt(pow(n.conv - totalConv, 2))*n.visits/totalVisits), 0
convAverage = fold-real-nodes root, ((n, acc) -> acc + n.conv*n.visits/totalVisits), 0

console.log totalConv
console.log convAverage
console.log convStnDev


root = kill-children 100, root



sor = (a,b) -> if (!!a and a.length > 0 and a != ' ') then a else b

color = d3.scale.quantile().range ['#ffe866', '#fefd69', '#eafd6d', '#d5fc70', '#c2fa74', '#b1f977', '#a0f87a', '#91f77e', '#83f681', '#84f592', '#87f4a4', '#8af2b5', '#8df1c4', '#90f0d3', '#93efe0', '#96eeec', '#99e3ed', '#9cd7eb', '#9fccea', '#a2c3e9']
color.domain([0, root.conv+2*convStnDev])

nodes = tree.nodes(root)
links = tree.links(nodes)
link = svg.selectAll("path.link").data(links).enter().append("path").attr("class", "link").attr("d", diagonal)
node = svg.selectAll("g.node").data(nodes).enter().append("g").attr("class", "node").attr("transform", (d) ->
	"translate(" + d.y + "," + d.x + ")"
)
node.append("circle").attr "r", 4.5
node.append("text").attr("dx", (d) ->
	(if d.children.length > 0 then -8 else 8)
).attr("dy", 3).attr("text-anchor", (d) ->
	(if d.children.length > 0 then "end" else "start")
).text((d) -> (d.device `sor` d.brand `sor` d.os))
.attr('fill', -> color it.conv)
.on('mouseover', ->
	console.log it.visits, it.conv
)


d3.select(self.frameElement).style "height", height + "px"
