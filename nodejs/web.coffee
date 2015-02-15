require 'coffee-script/register'
http        = require 'http'
{WSHandler} = require './WSHandler.coffee'
{logger}    = require './logger.coffee'


main = () ->
  logger = new logger()
  server = http.createServer handleHttpReq

  port  = process.env.PORT || 8080
  server.listen port, () ->
    logger.log "Server is listening on port #{port}"

  wsHandler = new WSHandler(server,logger)

handleHttpReq = (req, res) ->
  logger.logHTTP req, "Received request for #{req.url}"
  res.writeHead 200
  res.end "hello world", "utf8"

main()
