{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'
request = require 'request'
treefy = (require './treefy').treefy

# lower-case stats {visits, subscribers} property names
lower-case-data = (data) ->
	data = (map (-> it[0].stats = it[1]; it[0]) <| [[a,[{method:s.Method, visits: s.Visits, subscribers: s.Subscribers} for s in sx]] for [a,sx] in  [[a,a.stats] for a in data]])

request-json = (url, callback) -->
	(,,body) <- request url
	callback <| JSON.parse body

# removes null or undefined values from the map and creates Url + QueryString
# [[QueryStringName, Value]] -> String -> String
make-request-path-and-queryString = (nameValueMap, url) -->
	(-> url + '?' + it) <| join '&' <| map (-> it[0] + '=' + it[1]) <| filter (-> !!it[1]), nameValueMap

get-stats = (fromDate, toDate, visits, country, ref, callback) -->
	#url = "http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetStats?start_date=#{from}&end_date=#{to}&country_id=#{country}&visits=#{visits}&ref_id=#{ref}" 
	url = make-request-path-and-queryString [['start_date', fromDate],['end_date', toDate],['country_id', country],['visits', visits], ['ref_id', ref]], 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetStats'
	console.log "api << ", url
	obj <- request-json url
	callback lower-case-data obj

get-stats-by-superCampaign = (from, to, visits, superCampaign, ref, callback) -->
	url = "http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetStats?start_date=#{from}&end_date=#{to}&supercamp_id=#{superCampaign}&visits=#{visits}&ref_id=#{ref}" 
	console.log "api << ", url
	obj <- request-json url
	callback lower-case-data obj

get-test-stats = (testid, fromDate, toDate, country, callback) -->
	url = make-request-path-and-queryString [['test_id', testid],['start_date', fromDate],['end_date', toDate],['country_id', country]], 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetTestStats'
	console.log "api << ", url
	obj <- request-json url
	callback lower-case-data obj


exports.get-stats = get-stats


# stats-

exports.stats-tree = (fromDate, toDate, visits = 0, country = 0, ref = null, callback) ->
	console.log 'stats-tree', ref
	data <- (get-stats fromDate, toDate, visits, country, ref)
	callback <| treefy data

exports.stats-tree-by-superCampaign = (fromDate, toDate, visits = 0, superCampaign = 0, ref = null, callback) ->
	data <- (get-stats-by-superCampaign fromDate, toDate, visits, superCampaign, ref)
	callback <| treefy data

exports.stats-summary = (fromDate, toDate, visits = 0, country = 0, ref = null, callback) ->
	data <- (get-stats fromDate, toDate, visits, country, ref)
	callback <| format data

# test-

exports.test-tree = (testId, fromDate, toDate, country = 0, callback) ->
	data <- (get-test-stats testId, fromDate, toDate, country)
	callback <| treefy data

exports.test-summary = (testId, fromDate, toDate, country = 0, callback) ->
	data <- (get-test-stats testId, fromDate, toDate, country)
	callback <| format data

exports.tests-list = (activeOnly, callback) ->
	raw <- request-json "http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetTestsSummary?status=#{if activeOnly then 'Active' else 'none'}"

	callback <| [{
		id: r.Test_ID
		start: r.StartDate
		end:r.EndDate
		device:r.device
		status: r.Status
		visits: r.Visits
	} for r in raw]


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