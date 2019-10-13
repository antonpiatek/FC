mqtt = require 'mqtt'
RRD = require('rrd').RRD

main = ->
  client = mqtt.connect 'mqtt://localhost:1883', {protocolVersion: 3,   protocolId: 'MQIsdp' }
  client.on 'connect', () ->
    console.log "mqtt connected"
  client.on 'close', () ->
    console.warn "mqtt connection closed"
  client.on 'error', (e) ->
    console.warn "mqtt error #{e}"

  client.subscribe 'temperatures/byName/#', (err,ok) ->
    console.err err if err?
    console.dir if ok?
  client.subscribe 'PowerMeter/#', (err,ok) ->
    console.err err if err?
    console.dir if ok?

  client.on 'message', (topic, message) =>
    topic = topic.trim() #looks like my old topic all have a trailing space!
    message=JSON.parse message
    if (topic.indexOf "PowerMeter") is 0
      updatePower topic, message
    else if (topic.indexOf "temperatures/byName") is 0
      processTemp topic, message

updatePower = (topic, message)->
  console.log "UPDATING RRD POWER", message.value
  #TODO last garage temp? Probably best to update the temperatures rrd file for it
  rrd_power.update new Date(), [message.value,""], (err) ->
    if err
      console.log "error: #{err}"

processTemp = (topic, message)->
  parts = topic.split "/"
  if parts.length ==3
    room = mapRoomName parts[2]
    console.log " > TEMP", room, message.value
    temps[room] ?= {}
    temps[room]["value"] = message.value
    temps[room]["time"] = new Date
  else
    console.error "not sure how to parse temp topic #{topic}"
    console.log parts

# convert room names for rrdtool (actually may not be required as the update doesn't use the names, but easier to see everything line up properly)
mapRoomName = (room) ->
  switch room
    when "Nursery" then return "SpareRm"
    else return room

#update temperatures every so often
setInterval ->
  # rrd needs all values together so do a batch update, filtering values older than
  maxDiff = 180#sec
  #my rrd currently supports: 
  rooms = ["LivingRm","Bedroom","SpareRm","Outside"]
  updates = {}
  for i in rooms
    diff
    if temps[i]?["time"]
      diff = (new Date - temps[i]?["time"]) / 1000
    if temps[i]?["value"] and diff < maxDiff
      updates[i] = temps[i]["value"]
    else
      updates[i] = ""
  console.dir ["UPDATING RRD",updates], {colors:true}
  rrd_temp.update new Date(), [ updates["LivingRm"],updates["Bedroom"],updates["SpareRm"],updates["Outside"]], (err) ->
    if err
      console.log "error: #{err}"
, 5*1000
#TODO: Seems rrd logs very, very frequently... shouldnt need to log every 5 sec

temps = {}
rrd_power = new RRD "/home/anton/bin/cc/currentcost.rrd"
rrd_temp = new RRD "/home/anton/arduino/FC/temperatures.rrd"
main()
