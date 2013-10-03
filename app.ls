express = require 'express'
path = require 'path'
http = require 'http'
moment = require 'moment'
stats = (require './stats/stats')

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


fill-missing-prarams = (p) ->
	p.from = p.from or moment().format("YYYY-MM-DD")
	p.to = p.to or moment().add('days',1).format("YYYY-MM-DD")
	p


app.get '/', (require './routes').index



api-get = (url, transform) ->
	app.get url, (req, res) ->
		p = fill-missing-prarams req.params
		obj <- transform p
		api-res-end res, obj
api-res-end = (res, obj) -->
	res.writeHead(200,	 {'Content-Type': 'application/json'});
	(res.end . JSON.stringify) obj


# test

api-get '/api/test/tree/:testid/:from?/:to?/:country?', (p, callback) -> stats.test-tree p.testid,p.from,p.to, p.country, callback

api-get '/api/test/summary/:testid/:from?/:to?/:country?', (p, callback) -> stats.test-summary p.testid,p.from,p.to, p.country, callback


# stats

api-get '/api/stats/tree/:from?/:to?/:country?/:visits?', (p, callback) -> stats.stats-tree p.from,p.to, p.visits, p.country, callback

api-get '/api/stats/summary/:from?/:to?/:country?/:visits?', (p, callback) -> stats.stats-summary p.from,p.to, p.visits, p.country, callback




_ <- http.createServer(app).listen app.get('port')
console.log "express started at port " + app.get('port')
