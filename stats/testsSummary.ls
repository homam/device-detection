{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'
request = require 'request'
request-json = (url, callback) -->
	(,,body) <- request url
	callback <| JSON.parse body

raw <- request-json "http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetTestsSummary?status=Active"

console.log [{
	id: r.Test_ID
	start: r.StartDate
	end:r.EndDate
	device:r.device
	status: r.Status
	visits: r.Visits
	} for r in raw]