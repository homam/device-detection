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
countryId = (find (-> it.name == 'UAE'), country-ids).id

now = moment()


next = (days) ->

	fromDate = moment('2013-08-12').add('days', days)

	country = 2

	obj <- get-stats fromDate.format("YYYY-MM-DD"), fromDate.add('days', 1).format("YYYY-MM-DD"), 0, countryId

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

	_<- fs.writeFile 'data/ae-' + (fromDate.add('days', -1).format('YYYY-MM-DD')) + '.csv', (json2csv data)
	if not fromDate.add('days', 1).isAfter(now)
		next(days+1)


next 0
#console.log json2csv data


 # { brand: 'ZTE',
 #    device: 'zte_vf945_ver1_subuavodaupdate1',
 #    fall_back: 'zte_vf945_ver1',
 #    id: 14162,
 #    ishtml5: 'full',
 #    model: 'VF945',
 #    os: 'Android',
 #    stats: [ [Object] ],
 #    version: '2.1' } 

 #brand_name,model_name,wurfl_device_id,wurfl_fall_back,Method,Visits,Op Sel Visits,Op Sel Visits Only,LP Visits,
 #Submissions,Subscribers,Conv,RealConv,marketing_name,device_os,device_os_version,release_date,mobile_browser