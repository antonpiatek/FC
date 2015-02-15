exports.logger =
  class logger
    constructor: () ->
      @log "new logger"
    #TODO replace with logging framework - winston?
    log: (msg) ->
      console.log "#{new Date} #{msg}"
    warn: (msg) ->
      console.warn "#{new Date} #{msg}"
    logHTTP: (req,msg) ->
      ip = req.remoteAddress || req.connection.remoteAddress
      @log "#{ip} #{msg}"
    warnHTTP: (req,msg) ->
      ip = req.remoteAddress || req.connection.remoteAddress
      @warn "#{ip} #{msg}"
