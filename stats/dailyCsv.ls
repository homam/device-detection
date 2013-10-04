{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'
stats = (require './stats')
json2csv = (require './json2csv').json2csv
moment = require 'moment'
fs = require 'fs'

get-stats = stats.get-stats

request = require 'request'
request-json = (url, callback) -->
	(,,body) <- request url
	callback <| JSON.parse body
country-ids <- request-json 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetAllCountries'


countries = [['KSA', 'sa'], ['Kuwait', 'kw'], ['Bahrain', 'bh'], ['Jordan', 'jo'], ['Qatar', 'qa'], ['Iraq', 'iq'], ['Thailand', 'th'], ['Azerbaijan', 'az']]

now = moment()



next = (days, country, done) ->

	fromDate = moment('2013-08-12').add('days', days)

	console.log 'next', country, fromDate.format("YYYY-MM-DD")

	obj <- get-stats fromDate.format("YYYY-MM-DD"), fromDate.add('days', 1).format("YYYY-MM-DD"), 0, country.id

	data = flatten [[{
		brand_name: d.brand,
		model_name: d.model,
		wurfl_device_id: d.device,
		wurfl_fall_back: d.fall_back,
		Method: m.method
		Visits: m.visits,
		'Op Sel Visits': 0,
		'Op Sel Visits Only': 0,
		'LP Visits': m.visits,
		Submissions: 0,
		Subscribers: m.subscribers,
		Conv: m.subscribers/m.visits,
		RealConv: m.subscribers/m.visits,
		marketing_name: d.brand + ' ' + d.model,
		device_os: d.os,
		device_os_version: 0,
		release_date: '',
		mobile_browser: ''	

		} for m in d.stats] for d in obj]

	_<- fs.writeFile 'data/' + country.code + '-' + (fromDate.add('days', -1).format('YYYY-MM-DD')) + '.csv', (json2csv data)
	if not fromDate.add('days', 1).isAfter(now)
		next(days+1, country, done)
	else
		done()



next-country = (i) ->
	[name, code] = countries[i]
	countryId = (find (-> it.name == name), country-ids).id
	console.log code, countryId
	_ <- next 0, {code:code, id: countryId}
	if i < countries.length-1
		next-country(i+1)

next-country 0