express = require 'express'
path = require 'path'
http = require 'http'
moment = require 'moment'
stats = require './stats/stats'


app = express()
app.use express.static '/.public'
app.set 'port', (process.env.PORT or 3000)
app.set 'views', __dirname + '/views'
app.set 'view engine', 'ejs'
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

app.use express.favicon()

app.use express.static __dirname + '/public'
app.use '/javascript', express.static 'public/javascript'

app.use require('less-middleware') {src: __dirname + '/public'}
app.use require('connect-coffee-script') ({
	src: __dirname + '/public'
	bare: true})


app.get '/', (req, res) -> res.render 'home/index', {title: ''}
app.use '/home/javascript', express.static 'views/home/javascript'
app.use '/home/style', express.static 'views/home/style'

# src: __dirname,
#    compile: (str, path) -> stylus(str).set('filename', path).set('compress', true).use(nib())


param-val = (parser, v) --> 
	if (typeof(v) === 'undefined' or v === null or '-' === v) then null else (parser v)
param-identity-val = param-val (->it)
param-int-val = param-val parseInt

fill-missing-prarams = (p) ->
	p.from = param-identity-val(p.from) or moment().format("YYYY-MM-DD")
	p.to = param-identity-val(p.to) or moment().add('days',1).format("YYYY-MM-DD")
	p.country =  param-int-val(p.country)
	p.ref = param-int-val(p.ref)
	p.superCampaign = param-int-val(p.superCampaign)
	p

api-get = (url, transform) ->
	app.get url, (req, res) ->
		p = fill-missing-prarams req.params
		obj <- transform p
		api-res-end res, obj
api-res-end = (res, obj) -->
	res.writeHead(200,	 {'Content-Type': 'application/json'});
	(res.end . JSON.stringify) obj


# test

api-get '/api/test/tree/:testid/:from?/:to?/:country?/:ref?', (p, callback) -> stats.test-tree p.testid,p.from,p.to, p.country, callback

api-get '/api/test/summary/:testid/:from?/:to?/:country?', (p, callback) -> stats.test-summary p.testid,p.from,p.to, p.country, callback

api-get '/api/tests/:activeOnly?', (p, callback) -> stats.tests-list p.activeOnly, callback


# stats

api-get '/api/stats/tree/:from?/:to?/:country?/:ref?/:visits?', (p, callback) -> stats.stats-tree p.from,p.to, p.visits, p.country, p.ref, callback

api-get '/api/stats/summary/:from?/:to?/:country?/:ref?/:visits?', (p, callback) -> stats.stats-summary p.from,p.to, p.visits, p.country, p.ref, callback

api-get '/api/stats/tree-by-superCampaign/:from?/:to?/:superCampaign?/:ref?/:visits?', (p, callback) -> stats.stats-tree-by-superCampaign p.from,p.to, p.visits, p.superCampaign, p.ref, callback


_ <- http.createServer(app).listen app.get('port')
console.log "express started at port " + app.get('port')
