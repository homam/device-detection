prelude = require('prelude-ls')
{Obj,map, filter, each, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'

listOfSubscriptioMethods = [{"id":0,"name":"Unknown", label: "??"},{"id":11,"name":"WAP", label: "DW"},{"id":1,"name":"sms", label: "SMS"},{"id":2,"name":"smsto", label: "STO"},{"id":3,"name":"mailto", label: "MTO"},{"id":7,"name":"SMS_WAP", label: "MO"},{"id":8,"name":"LINKCLICK", label: "LKC"},{"id":6,"name":"JAVA_APP", label: "JA"},{"id":4,"name":"LinkAndPIN", label: "LnP"},{"id":5,"name":"LinkAndPrefilledPIN", label: "LnPP"},{"id":9,"name":"WAPPIN", label: "Pin"},{"id":10,"name":"GooglePlay", label: "GP"}]

# utility functions region

format-date = d3.time.format('%Y-%m-%d')

hard-clone = -> JSON.parse JSON.stringify it

trace = (v) ->
	console.log v
	v

# end utility functions region


treeChart = tree-map(1300,500) # tree-long-branches(1000,1000) 


$ ->
	$(window).on "tree/node-selected", (.., node)->
		#vTotal = sum-visits (->true), node
		#[vSelected, sSelected, cSelected]  = selected-stats node
		$li = d3.select('.node-methods-stats').selectAll('li').data(node.stats)
		$liEnter = $li.enter().append('li')
		render-method-stats = (className, text) -> 
			$liEnter.append("span").attr("class", className)
			$li.select("span.#{className}").text(text)
		each (-> render-method-stats it, (m) -> m[it]), ['method', 'visits', 'subscribers']
		render-method-stats 'converson', (m) -> d3.format('.1%')(if m.visits == 0 then 0 else (m.subscribers / m.visits))

$ ->
	root = null

	update-tree-from-ui = ->
		treeChart.update-tree hard-clone(root), $('#chosen-methods').val(), $('#chosen-methods-orand').is(':checked'), true, parseInt($('#kill-children-threshold').val())



	# header
	d3.select('#chosen-methods').selectAll('option').data(listOfSubscriptioMethods)
	.enter().append('option').text(-> it.name)
	$('#chosen-methods').chosen().change(->update-tree-from-ui())

	$('#chosen-methods-orand').change(->
		$('#kill-children-threshold').val(0)
		update-tree-from-ui())

	countries <- $.get 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetAllCountries'
	d3.select('#chosen-countries').selectAll('option').data(countries)
	.enter().append('option').attr("value", -> it.id).text(-> it.name)

	$('#chosen-countries').chosen({allow_single_deselect: true}).change(->re-root())

	now = new Date()
	$('#fromDate').attr("max", format-date new Date(now.valueOf()-1*24*60*60*1000))
	.val(format-date new Date(now.valueOf()-2*24*60*60*1000))
	.change(->re-root())

	$('#toDate').attr("max", format-date now)
	.val(format-date new Date(now.valueOf()-1*24*60*60*1000))
	.change(->re-root())


	re-root = ->
		#r <- $.get "data/ae.json"
		r <- $.get "/api/stats/tree/#{$('#fromDate').val()}/#{$('#toDate').val()}/#{$('#chosen-countries').val()}/0"
		root := r
		update-tree-from-ui()

	re-root()




