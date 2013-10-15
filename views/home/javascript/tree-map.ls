prelude = require('prelude-ls')
{Obj,map, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'

pow = Math.pow
sqrt = Math.sqrt

# utility functions 

sor = (a,b) -> if (!!a and a.length > 0 and a != ' ') then a else b

shorten-wurfl-device-name = (name) ->
	if !name 
		return name
	verIndex = name.indexOf("ver")
	return if verIndex > 0 then name.substr(0, verIndex+1) + '..' else name



exports = exports or this

exports.tree-map = (width = 1000, height = 1000) ->

	$svg = d3.select(".tree").append("svg").attr("width", width).attr("height", height).append("g").attr("transform", "translate(-.5,-.5)")

	# root :: Node
	# selectedSubscriptionMethods :: [String]
	# selectedSubscriptionMethodsOr :: Bool
	# call this function to update the UI and the tree graphics
	update-tree = (root, selected-stats) ->

		[totalVisitsSelected,totalSubscribersSelected,convAverageSelected] = selected-stats root

		# utility for animating transition
		transition = (node) -> node.transition().duration(500)

		color = d3.scale.quantile().range ['#d94f34', '#d69838', '#cdd43c', '#8ad240', '#4dd044', '#48cd7a', '#4ccbb4', '#4fa9c9', '#5375c6', '#6656c4']
		color.domain([0, convAverageSelected])

		

		# the actual d3 code region

		treemap = d3.layout.treemap().padding(0).size([width, height]).value(-> selected-stats(it)[0]) # selected-stats :: Node -> [Visits, Subscribers, Conv]

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

		#$render-node-methods-stats root


	$(window).on "tree/node-selected", (.., node) ->
		d3.selectAll('rect.selected').classed('selected', false) # deselect currently selected one
		d3.select(".node-#{node.treeId}").classed('selected', true)



	# return
	{	
		$svg,
		update-tree
	}

