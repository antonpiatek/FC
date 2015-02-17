wsConn = new WebSocket "ws://192.168.0.2:8080/", "ant-protocol"
wsConn.onmessage = (event) ->
  data=JSON.parse event.data
  updateDebug(event,data)
  if event.timeStamp < new Date()-30
    console.error "timestamp is more than 30 s out"
    return
  parts = data.topic.split "/" 
  updated=false
  if parts.length == 2
    id=parts[0]+"_"+parts[1]
    target=$("##{id}")
    if target.length
      target.children("span.value").html data.message
      updated=true
    else
      categoryObj = $("#"+parts[0])
      if categoryObj.length
        categoryObj.after "<div id='#{id}'>#{parts[1]} <span class='value badge'>#{data.message}</span></div>"
        updated=true
      else
        console.warn "unknown topic category #{parts[0]}"
  else
    console.warn "no idea what to do with #{parts}"

  if updated
    $("#lastUpdate").html(Date())

updateDebug= (event,data) ->
  debug = $("#debug")
  $("#debug").prepend "<div>"+data.message+" "+data.topic+"</div>"
  if debug.children().length >= 5
    debug.children()[4].remove()

