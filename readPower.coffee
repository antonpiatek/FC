SerialPort = require 'serialport'
{parseString} = require 'xml2js'
MQTT = require 'mqtt'
fs = require 'fs'

port   = '/dev/ttyUSB0'

#TODO: make this OO so I don't have to pass mqtt everywhere....
readSerial = (mqtt) ->
  mqtt.publish 'test', 'Hello mqtt'

  serial = new SerialPort port, baudrate: 9600, parser: SerialPort.parsers.readline("\n")
  serial.on 'data', (data) ->
    try
      parseString data, (err, data) ->
        if err
          console.error err
        else
          parseData data, mqtt
    catch e
      console.error e

parseData = (data, mqtt) ->
  if data.msg
    data = data.msg
    # data also has date[0] which has the following fields
    # { dsb: [ '02476' ], hr: [ '17' ], min: [ '15' ], sec: [ '06' ] }
    # but I really don't think we care, or even trust its clock
    if data.ch1?[0].watts
      publishWatts(+data.ch1[0].watts, mqtt)
    if data.tmpr
      publishTemp(+data.tmpr[0], mqtt)
    if data.hist
      console.log "TODO: Do something with history data...?"
      #TODO: If we do do something with the historical readings, look out for a new value for days/months/etc but don't trust its clock!
      #Probably should save them to myqsl power.archive, or port the whole lot to a text file? Not much point unless I redo my ancient google charts to show the data
      #if data.hist ?
      #  data.hist.hrs.h02-26#?! 26!
      #  data.hist.days.d01
      #  data.hist.mths.m01
      #  data.hist.yrs.y1

publishWatts = (watts, mqtt) ->
  publish("PowerMeter/watts", watts, mqtt)

publishTemp = (temp, mqtt) ->
  publish("temperatures/byName/Garage", temp, mqtt)

publish = (topic, value, mqtt) ->
  msg =
    value: value
    time: new Date()
  mqtt.publish topic, JSON.stringify msg, {retain:true}
  console.log "publishing #{topic} #{value}"

mqttConnect = () ->
  client = MQTT.connect 'mqtt://localhost:1883', {protocolVersion: 3,   protocolId: 'MQIsdp' }
  client.on 'connect', () ->
    console.log "mqtt connected"
    readSerial(client)
  client.on 'close', () ->
    console.warn "mqtt connection closed"
  client.on 'error', (e) ->
    console.warn "mqtt error #{e}"
  
console.log "Starting..."
fs.stat port, (err, stats) ->
  if err
    console.error "Couldn't stat #{port}"
    process.exit()
mqttConnect()
