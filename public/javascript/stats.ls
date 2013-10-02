{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'
request = require 'request'
treefy = (require './treefy').treefy

# lower-case stats {visits, subscribers} property names
lower-case-data = (data) ->
	data = (map (-> it[0].stats = it[1]; it[0]) <| [[a,[{method:s.Method, visits: s.Visits, subscribers: s.Subscribers} for s in sx]] for [a,sx] in  [[a,a.stats] for a in data]])

request-json = (url, callback) -->
	(,,body) <- request url
	callback <| JSON.parse body


get-test-stats = (testid, from, to, country, callback) -->
	url = "http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetTestStats?test_id=#{testid}&start_date=#{from}&end_date=#{to}&country_id=#{country}&visits=0" 
	#console.log url
	request-json url, callback



exports.test-tree = (testId, fromDate, toDate, country = 0, callback) ->
	data <- (get-test-stats testId, fromDate, toDate, country)
	callback <| treefy lower-case-data data

exports.test-summary = (testId, fromDate, toDate, country = 0, callback) ->
	data <- (get-test-stats testId, fromDate, toDate, country)
	callback <| format lower-case-data data




format = (data) ->

	format = (s, v) -->
		| '%' == s 	=> (Math.floor(v*10000)/100) + '%'
		| otherwise	=> v

	percent-format = format '%'

	method-groups = (map (.stats)) >> flatten >> (group-by (.method)) #>> Obj.map (.data)

	sumProp = (p) -> (map (a) -> a[p]) >> sum


	(-> [[a, {visits: v, subscribers: s, conversion: percent-format s/v}] for [a,v,s] in it]) 
		<| (-> [[a, (sumProp 'visits')(b), (sumProp 'subscribers')(b)] for [a,b] in it]) 
		<| obj-to-pairs <| method-groups data	




	#get-country-id = (name) -> (filter (.name == name), country-ids)[0].id