require 'coffee-script/register'
express     = require 'express'
errorHandler = require 'error-handler'
morgan       = require 'morgan'
http         = require 'http'
path         = require 'path'
{WSHandler}  = require './WSHandler'
{logger}     = require './logger'
routes       = require './routes'

app = express()
app.set 'port', process.env.PORT || 8080
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use morgan 'combined'
console.log path.join  __dirname,'public'
app.use express.static path.join __dirname,'public'

if process.env.NODE_ENV == 'development'
  app.use errorHandler
  app.locals.pretty = true
else
  # TODO

app.set 'baseurl', process.env.BASEURL || ''

app.get '/', routes.index
app.get '/partials/:name', routes.partials
app.all '*', (req, res, next) ->
  res.writeHead(404)
  res.end ->

server = app.listen app.get('port'), ->
  console.log "Listening on port #{app.get('port')}"

logger = new logger()
wsHandler = new WSHandler(server,logger)

