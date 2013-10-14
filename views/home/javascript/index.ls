prelude = require('prelude-ls')
{Obj,map, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'

listOfSubscriptioMethods = [{"id":0,"name":"Unknown", label: "??"},{"id":11,"name":"WAP", label: "DW"},{"id":1,"name":"sms", label: "SMS"},{"id":2,"name":"smsto", label: "STO"},{"id":3,"name":"mailto", label: "MTO"},{"id":7,"name":"SMS_WAP", label: "MO"},{"id":8,"name":"LINKCLICK", label: "LKC"},{"id":6,"name":"JAVA_APP", label: "JA"},{"id":4,"name":"LinkAndPIN", label: "LnP"},{"id":5,"name":"LinkAndPrefilledPIN", label: "LnPP"},{"id":9,"name":"WAPPIN", label: "Pin"},{"id":10,"name":"GooglePlay", label: "GP"}]

# utility functions region

format-date = d3.time.format('%Y-%m-%d')

pow = Math.pow
pow2 = (n) -> Math.pow n, 2
sqrt = Math.sqrt

sor = (a,b) -> if (!!a and a.length > 0 and a != ' ') then a else b

hard-clone = -> JSON.parse JSON.stringify it

trace = (v) ->
	console.log v
	v

# end utility functions region

treeUiTypes = {
	'tree-long-branches': tree-long-branches
	'tree-map': tree-map,
	'devices-histogram': devices-histogram
}

treeChart = devices-histogram(screen.width-10,1000) #tree-map(1300,500) # tree-long-branches(1000,1000) 


$ ->
	update-stats-at-footer = (node) ->

		allMethodsSummary = fold ((acc, a) -> {visits: a.visits+acc.visits, subscribers: a.subscribers+acc.subscribers}), {visits: 0, subscribers: 0}, node.stats
		allMethodsSummary.conversion = allMethodsSummary.subscribers/allMethodsSummary.visits
		$summarySpan = d3.select('.all-methods-summary').selectAll('span').data(obj-to-pairs allMethodsSummary)
		$summarySpan.enter().append('span').attr('class',->it[0])
		$summarySpan.text(-> (if 'conversion' == it[0] then d3.format('.1%') else d3.format(','))  it[1])


		# render stats for each subscription method
		$li = d3.select('.node-methods-stats').selectAll('li').data(node.stats)
		$liEnter = $li.enter().append('li')
		$li.exit().remove()
		render-method-stats = (className, text) -> 
			$liEnter.append("span").attr("class", className)
			$li.select("span.#{className}").text(text)
		each (-> render-method-stats it, (m) -> m[it]), ['method', 'visits', 'subscribers']
		render-method-stats 'conversion', (m) -> d3.format('.1%')(if m.visits == 0 then 0 else (m.subscribers / m.visits))
		$li.transition().duration(200).style("opacity", (-> 
			ratio = it.visits / allMethodsSummary.visits
			d3.scale.linear().domain([0,0.33]).range([0.2,1]).clamp(true)(ratio)
		))
			#if it.visits < (allMethodsSummary.visits * 0.1) then 0.5 else 1))


	#  event handler: node clicked
	$(window).on "tree/node-selected", (.., node)->
		#vTotal = sum-visits (->true), node
		#[vSelected, sSelected, cSelected]  = selected-stats node
		name-node = (n) -> n.device `sor` n.brand `sor` n.os `sor` ''

		all-parents = (n, list) ->
			| !n.parent => [n] ++ list
			| otherwise => all-parents(n.parent, list) ++ [n] ++ list


		select-node = (n) ->
			console.log 'select-node', n.treeId, n
			d3.selectAll('rect.selected').classed('selected', false) # deselect currently selected one
			d3.select(".node-#{n.treeId}").classed('selected', true)
			update-stats-at-footer n


		select-node node

		$('.stats h2').html('')
		names = (all-parents node, []) #map (->{id: it.treeId, name: name-node(it)}), (all-parents node, [])
		$a = d3.select('.stats h2').selectAll('a').data(names)
		.enter().append('a').text(->name-node(it)).on('click', -> select-node it)
$ ->
	root = null

	change-tree-ui = (type) ->
		$(".tree").html('')

		treeChart := treeUiTypes[type](screen.width-10,1000)
		update-tree-from-ui!

	update-tree-from-ui = ->
		if !root.stats then
			#$(".tree").html('Nothing!')
			console.log 'nothing!'
			return

		lastId = 0
		add-id-to-node = (n) ->
			| !n.children or n.children.length == 0 => n.treeId = ++lastId
			| otherwise => n.treeId = ++lastId; each (add-id-to-node), n.children

		add-id-to-node root


		find-method = (name, stats) ->
			(find (-> it.method == name), stats) or {visits: 0, subscribers: 0}
		
		calc-conv = (m) ->
			if m.visits == 0 then 0 else m.subscribers/m.visits

		# in utils.ls
		stndDev-of-conversion-for-method = (methodName, node) -> 
			sqrt fold-real-nodes node, ((n, acc) ->
				if !!n.children and n.children.length>0
					return 0
				
				method = find-method methodName, n.stats
				rootMethod = find-method methodName, node.stats

				v = pow2(calc-conv(method) - calc-conv(rootMethod)) * method.visits/rootMethod.visits

				return v+acc
			), 0

		
		#console.log [[name, calc-conv(find-method(name, root.stats)), (stndDev-of-conversion-for-method name, root)] for  {id,name} in listOfSubscriptioMethods]

		treeChart.update-tree hard-clone(root), $('#chosen-methods').val(), $('#chosen-methods-orand').is(':checked'), true, parseInt($('#kill-children-threshold').val())


	val = (cssSelector) -> $(cssSelector).val() || '-'

	re-root = (url) -->
		$('#loading').show()
		setTimeout (-> $('#loading').addClass('visible')), 500
		#url = "data/ae.json"
		console.log '*** ', url
		r <- $.get url
		root := r
		update-tree-from-ui!
		$('#loading').removeClass('visible')
		setTimeout (-> $('#loading').hide()), 500

	re-root-again = null

	re-root-country = ->
		$('#chosen-superCampaigns').select2('val', '')

		url = if !$('#chosen-tests').val() or parseInt($('#chosen-tests').val()) == 0 then
			"/api/stats/tree/#{val('#fromDate')}/#{val('#toDate')}/#{val('#chosen-countries')}/#{val('#chosen-refs')}/0"
		else
			"/api/test/tree/#{val('#chosen-tests')}/#{val('#fromDate')}/#{val('#toDate')}/#{val('#chosen-countries')}/#{val('#chosen-refs')}"

		re-root-again := re-root-country
		re-root url

	re-root-superCampaign = ->
		$('#chosen-countries, #chosen-refs, #chosen-tests').select2('val','')

		url = "/api/stats/tree-by-superCampaign/#{val('#fromDate')}/#{val('#toDate')}/#{val('#chosen-superCampaigns')}/#{val('#chosen-refs')}/0"

		re-root-again := re-root-superCampaign
		re-root url

	re-root-again = re-root-country	


	# header
	d3.select('#chosen-methods').selectAll('option').data(listOfSubscriptioMethods)
	.enter().append('option').text(-> it.name)
	$('#chosen-methods').select2({width: 'element'}).change(->update-tree-from-ui())

	$('#chosen-methods-orand').change ->
		$('#kill-children-threshold').val(if $(this).is(':checked') then 100 else 0)
		update-tree-from-ui!

	$('#kill-children-threshold').change(->update-tree-from-ui!)

	# callback :: ($jQuerySelect) -> void
	populate-chosen-select = ($select, url, mapFunc, defaultValue, callback) ->
		data <- $.get url
		data  = mapFunc data
		d3.select($select[0]).selectAll('option').data(data)
		.enter().append('option').attr("value", -> it.id).text(-> it.name)
		$select.select2({width: 'element', allowClear: true}).select2('val', defaultValue)
		callback $select


	
	_ <- populate-chosen-select($('#chosen-countries').on('change', -> re-root-country!), 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetAllCountries', 
		((countries) -> [{}] ++ countries), 2) # select uae as the intial country TODO: get it from query string

	do ->
		_ <- populate-chosen-select($('#chosen-refs').on('change', -> re-root-again!), 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetRefs',
			((refs)-> refs[0] = {}; refs), '') # TODO: get default ref from QueryString

		_ <- populate-chosen-select($('#chosen-superCampaigns').on('change', -> re-root-superCampaign!), 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetSuperCampaigns',
			((superCampaigns)->  [{}] ++ (filter (-> it.name.indexOf('[') != 0), superCampaigns)), '') # TODO: get default ref from QueryString


		_ <- populate-chosen-select($('#chosen-tests').on('change', -> re-root-again!), '/api/tests/true',
			((tests)->  [{}] ++ [{id: t.id, name: "#{t.device} (#{t.id})"} for t in tests]), '')


	now = new Date()
	$('#fromDate').attr("max", format-date new Date(now.valueOf()-1*24*60*60*1000))
	.val(format-date new Date(now.valueOf()-2*24*60*60*1000))
	.change(->re-root-again!)

	$('#toDate').attr("max", format-date now)
	.val(format-date new Date(now.valueOf()-1*24*60*60*1000))
	.change(->re-root-again!)

	$('#chosen-tree-ui-type').select2().change(-> change-tree-ui $(this).val())




	re-root-again!






