express = require 'express'
path = require 'path'
http = require 'http'
moment = require 'moment'
stats = (require './public/javascript/stats')

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



app.get '/', (require './routes').index
app.get '/api/test/tree/:testid/:from?/:to?/:country?', (req, res) ->
	p = req.params
	p.from = p.from or moment().format("YYYY-MM-DD")
	p.to = p.to or moment().add('days',1).format("YYYY-MM-DD")
	obj <- stats.test-tree(p.testid,p.from,p.to, p.country)
	# obj <- stats.test-summary(p.testid,p.from,p.to, p.country)
	res.writeHead(200, {'Content-Type': 'application/json'});
	(res.end . JSON.stringify) obj



_ <- http.createServer(app).listen app.get('port')
console.log "express started at port " + app.get('port')
