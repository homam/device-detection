{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'
request = require 'request'
request-json = (url, callback) -->
	(,,body) <- request url
	callback <| JSON.parse body

method-ids 	<- request-json 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetSubscriptionMethods'
country-ids <- request-json 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetAllCountries'


create-test = (countries, methods, wurflid) -->
	methods-str =  (join ',' <| [id for {id, name} in method-ids when name in methods])
	countries-str = (join ',' <| [id for {id,name} in country-ids when name in countries])
	"http://mobitransapi.mozook.com/devicetestingservice.svc/json/CreateDeviceTest?wurfl_id=#{wurflid}&methods=#{methods-str}&countries=#{countries-str}"


create-test-standard = create-test [ 'KSA', 'UAE', 'Kuwait', 'Bahrain', 'Oman', 'Jordan',' Qatar', 'Iraq', 'Azerbaijan' ]


console.log <| create-test-standard ['sms', 'JAVA_APP'], 13378
