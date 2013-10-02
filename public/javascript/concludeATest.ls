{Obj,map, filter, find, fold, foldr, fold1, all, flatten, sum, group-by, obj-to-pairs, partition, join, unique} = require 'prelude-ls'
request = require 'request'
request-json = (url, callback) -->
	(,,body) <- request url
	callback <| JSON.parse body

method-ids 	<- request-json 'http://mobitransapi.mozook.com/devicetestingservice.svc/json/GetSubscriptionMethods'


conclude-test = (prioMethods, fallbackMethods, methods, testid, wurflid) -->
	methods-str =  (join ',' <| (map (-> it.id)) <| (map ( (name)-> find (-> it.name == name), method-ids), prioMethods++methods++fallbackMethods ))
	"http://mobitransapi.mozook.com/devicetestingservice.svc/json/ConcludeDeviceTest?test_id=#{testid}&wurfl_id=#{wurflid}&methods=#{methods-str}"

create-test-standard = conclude-test ['WAP'], ['WAPPIN', 'SMS_WAP']


console.log <| create-test-standard ['JAVA_APP', 'sms', 'mailto'], 45, 15031
