
exports.WSHandler =
  class WSHandler

    ws   = require 'websocket'
    mqtt = require 'mqtt'
    
    constructor: (@server,@logger) ->
      @devel = process.env.NODE_ENV == 'development'
      @logger.log "new WSHandler"

      WebSocketServer = ws.server
      wsServer = new WebSocketServer {httpServer: @server, autoAcceptConnections: false}
      wsServer.on 'request', (req) => @requestHandler req

    originIsAllowed: (origin) ->
      # TODO put logic here to detect whether the specified origin is allowed.
      @logger.log origin
      # match same host as our server? 
      # http://192.168.0.2:8080
      return true if @devel # Allow things like a chrome WS plugin to connect

    requestHandler: (request) ->
      # Make sure we only accept requests from an allowed origin
      if ! @originIsAllowed request.origin
        request.reject
        @logger.warnHTTP request,' Connection from origin ' + request.origin + ' rejected.'
        return
      
      # /connect ws://192.168.0.2:8080 ant-protocol
      try
        connection = request.accept 'ant-protocol', request.origin
      catch e
        @logger.warnHTTP request, "rejected connection: #{e}"
        return
      @logger.logHTTP request, "WS connection accepted"

      mqttClient = @subscribeMQTT connection

      connection.on 'close', (reasonCode, description) =>
        @logger.logHTTP request, "WS connection closed"
        mqttClient.end () ->

    subscribeMQTT: (wsConn) ->
      #server is older version, set that here
      mqttClient = mqtt.connect 'mqtt://localhost:1883', {protocolVersion: 3,   protocolId: 'MQIsdp' }
      mqttClient.subscribe 'Temperatures/#', (err,ok) ->
        @logger.warnHTTP err if err?
        #TODO logger
        console.dir ok if ok?
      mqttClient.subscribe 'PowerMeter/#', (err,ok) ->
        @logger.warnHTTP err if err?
        #TODO logger
        console.dir ok if ok?

      mqttClient.on 'connect', () =>
        @logger.log "mqtt connected"
      mqttClient.on 'close', () =>
        @logger.warn "mqtt connection closed"
      mqttClient.on 'error', (e) =>
        @logger.warn "mqtt error #{e}"

      mqttClient.on 'message', (topic, message) =>
        @logger.log "mqtt >> #{topic} #{message}" if @devel
        topic = topic.trim() #looks like my old topic all have a trailing space!
        wsConn.sendUTF JSON.stringify {topic: topic, message: message.toString()}

      return mqttClient
