gauges = []

initGauge = (id,type, desc, value) ->
  opts = {
    renderTo  : id,
    width     : 250,
    height    : 250,
    glow      : true,
    title     : desc,
    #strokeTicks : false,
    animation : {
        delay : 10,
        duration: 300,
        fn : 'bounce'
    },
    highlights : false,
    colors     : {
    #  plate      : '#222',
    #  majorTicks : '#f5f5f5',
    #  minorTicks : '#ddd',
      title      : '#000',
      units      : '#000',
      numbers    : '#000',
      needle     : {
        start : 'rgba(240, 128, 128, 1)',
        end   : 'rgba(255, 160, 122, .9)'
      }
    }
  }
  if type == 'temperatures'
    opts.maxValue = 30
    opts.valueFormat = { int : 1, dec : 1 }
    opts.majorTicks = [0,5,10,15,20,25,30]
    opts.minorTicks = 5
    opts.units = "deg C"
    opts.highlights = [{
        from  : 0,
        to    : 5,
        color : '#00d'
    }, {
        from  : 5,
        to    : 17,
        color : 'LightBlue'
    }, {
        from  : 17,
        to    : 19,
        color : 'LightGreen'
    }, {
        from  : 19,
        to    : 30,
        color : 'LightSalmon'
    }]
    if desc == 'Outside'
      opts.majorTicks = [-5,0,5,10,15,20,25,30]
      opts.minValue = -5
      opts.highlights = [{
          from  : -5,
          to    : 0,
          color : '#00d'
      }, {
          from  : 0,
          to    : 18,
          color : 'LightBlue'
      }, {
          from  : 18,
          to    : 25,
          color : 'LightGreen'
      }, {
          from  : 25,
          to    : 30,
          color : 'LightSalmon'
      }]
  else if type == 'PowerMeter'
    opts.maxValue = 3500
    opts.majorTicks = [0,500,1000,1500,2000,2500,3000,3500]
    opts.minorTicks = 5
    opts.valueFormat = { int : 3, dec : 0 }
    opts.units = "Watts"
    opts.highlights = [{
        from  : 0,
        to    : 300,
        color : '#0d0'
    }, {
        from  : 300,
        to    : 1000,
        color : 'PaleGreen'
    }, {
        from  : 1000,
        to    : 1500,
        color : 'Khaki'
    }, {
        from  : 1500,
        to    : 2000,
        color : 'LightSalmon'
    }, {
        from  : 2000,
        to    : 3500,
        color : 'red'
    }]
  else
    console.error "unknown gauge type #{type}"

  gauge = new Gauge(opts)
  gauge.onready = ->
    gauge.setValue(value)
  gauge.draw()
  gauges[id] = gauge
  return

updateDebug = (event,data) ->
  debug = $("#debug")
  $("#debug").prepend "<div>"+data.message.value+" "+data.topic+"</div>"
  debug.children()[4]?.remove()


updateGauge = (id,temp) ->
  if gauges[id]?
    if temp != null
      gauges[id].setValue(temp)
    else
      guages[id].destroy()
      delete guages[id]
    return



ws = "ws://"
if location.protocol == 'https:'
  ws = "wss://"

wsConn = new WebSocket "#{ws}#{window.location.host}#{window.baseurl}", "ant-protocol"

wsConn.onclose = (event) ->
    console.error(event)
    debugger

wsConn.onerror = (event) ->
    console.error(event)
    debugger

wsConn.onmessage = (event) ->
  data=JSON.parse event.data
  updateDebug(event,data)
  #TODO: data is purely just a number, need to include the data timestamp i think
  # check data.message.time for time of source data
  if event.time < new Date()-30
    console.error "timestamp is more than 30 s out"
    return
  parts = data.topic.split "/"
  updated=false
  if parts.length == 2
    id="#{parts[0]}_#{parts[1]}"
    target=$("##{id}_gauge")
    if target.length
      target.children("span.value").html data.message.value
      updateGauge "#{id}_gauge", data.message.value
      updated=true
    else
      categoryObj = $("#"+parts[0])
      if categoryObj.length
        #categoryObj.after "<div id='#{id}'>#{parts[1]} <span class='value badge'>#{data.message}</span></div>"
        categoryObj.append "<canvas id='#{id}_gauge'/>"
        initGauge "#{id}_gauge",parts[0],parts[1],data.message.value
        updated=true
      else
        console.warn "unknown topic category #{parts[0]}"
  # New temperaturs are temperatures/byName/room
  else if parts.length == 3 and parts[1] == 'byName'
    id="#{parts[0]}_#{parts[2]}"
    target=$("##{id}_gauge")
    if target.length
      target.children("span.value").html data.message.value
      updateGauge "#{id}_gauge", data.message.value
      updated=true
    else
      categoryObj = $("#"+parts[0])
      if categoryObj.length
        #categoryObj.after "<div id='#{id}'>#{parts[1]} <span class='value badge'>#{data.message}</span></div>"
        categoryObj.append "<canvas id='#{id}_gauge'/>"
        initGauge "#{id}_gauge",parts[0],parts[2],data.message.value
        updated=true
      else
        console.warn "unknown topic category #{parts[0]}"
  else
    console.warn "no idea what to do with #{parts}"

  if updated
    $("#lastUpdate").html(Date())

#Hide default tabs
$("#overviewMain").siblings('div').hide()

#Nav bar hooks
$("#button_overview").click ->
  setNavActive($(this))
  $("#overviewMain").show()
  $("#overviewMain").siblings('div').hide()
$("#button_power").click ->
  setNavActive($(this))
  $("#powerMain").show()
  $("#powerMain").siblings('div').hide()

$("#button_temperature").click ->
  setNavActive($(this))
  $("#temperatureMain").show()
  $("#temperatureMain").siblings('div').hide()
  console.log "temp"

setNavActive = (button) ->
  button.siblings('li').removeClass 'active'
  button.addClass 'active'

