express = require 'express'
path = require 'path'
http = require 'http'

app = express()

app.use express.static '/.public'

app.set 'port', process.env.PORT or 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'ejs'
app.use express.logger 'dev'
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router

app.use express.favicon()

app.use express.static __dirname + '/public'
app.use '/javascript', express.static 'public/javascript'

app.use require('less-middleware')
  src: __dirname + '/public'
app.use require('connect-coffee-script')
  src: __dirname + '/public'
  bare: true



app.get '/', (require './routes').index
app.get '/api/test/tree/:testid/:from/:to?/:country', (req, res) ->
	p = req.params
	p.to = p.to or '2013-10-04'
	(require './public/javascript/stats').tree(p.testid,p.from,p.to, (obj) ->
		res.writeHead(200, {'Content-Type': 'application/json'});
		res.end JSON.stringify obj
	)



http.createServer(app).listen app.get('port'), ()->
  console.log "express started at port " + app.get('port')