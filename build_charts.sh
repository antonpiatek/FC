#!/bin/bash
OUTPATH=/home/anton/public_html/temp/
RRDFILE=~/arduino/FC/temperatures.rrd
WIDTH=800
#was 800x150, presumably for joggler
CHARTSIZE="--width $WIDTH --height 200"

#hour
rrdtool graph $OUTPATH/hour.png --start end-1h --width $WIDTH --height 100 --end now --title "Last Hour's Temps" \
  --slope-mode --vertical-label DegC --alt-autoscale-min --alt-autoscale-max \
  DEF:LivingRm=$RRDFILE:LivingRm:AVERAGE  LINE1:LivingRm#0000FF:"Living Room" \
  DEF:Bedroom=$RRDFILE:Bedroom:AVERAGE    LINE1:Bedroom#00FF00:"Bedroom" \
  DEF:SpareRm=$RRDFILE:SpareRm:AVERAGE    LINE1:SpareRm#FF00FF:"Nursery" \
  DEF:Outside=$RRDFILE:Outside:AVERAGE    LINE1:Outside#000000:"Outside" 
  #--slope-mode --vertical-label DegC --lower-limit 0 --alt-autoscale-max \

#day
rrdtool graph $OUTPATH/day.png --start end-1d --width $WIDTH --height 100 --end now --title "Last Day's Temps" \
  --slope-mode --vertical-label DegC --alt-autoscale-min --alt-autoscale-max \
  DEF:Outside=$RRDFILE:Outside:AVERAGE    LINE1:Outside#000000:"Outside" \
  GPRINT:Outside:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Outside:MAX:"Max\: %2.1lf" \
  GPRINT:Outside:MIN:"Min\: %2.1lf\t" \
  DEF:LivingRm=$RRDFILE:LivingRm:AVERAGE  LINE1:LivingRm#0000FF:"Living Room" \
  GPRINT:LivingRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:LivingRm:MAX:"Max\: %2.1lf" \
  GPRINT:LivingRm:MIN:"Min\: %2.1lf\n" \
  DEF:Bedroom=$RRDFILE:Bedroom:AVERAGE    LINE1:Bedroom#00FF00:"Bedroom" \
  GPRINT:Bedroom:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Bedroom:MAX:"Max\: %2.1lf" \
  GPRINT:Bedroom:MIN:"Min\: %2.1lf\t" \
  DEF:SpareRm=$RRDFILE:SpareRm:AVERAGE    LINE1:SpareRm#FF00FF:"Nursery" \
  GPRINT:SpareRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:SpareRm:MAX:"Max\: %2.1lf" \
  GPRINT:SpareRm:MIN:"Min\: %2.1lf\n" 

#week
rrdtool graph $OUTPATH/week.png --start end-7d --width $WIDTH --height 100 --end now --title "Last Week's Temps" \
  --slope-mode --vertical-label DegC --alt-autoscale-min --alt-autoscale-max \
  DEF:Outside=$RRDFILE:Outside:AVERAGE    LINE1:Outside#000000:"Outside" \
  GPRINT:Outside:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Outside:MAX:"Max\: %2.1lf" \
  GPRINT:Outside:MIN:"Min\: %2.1lf\t" \
  DEF:LivingRm=$RRDFILE:LivingRm:AVERAGE  LINE1:LivingRm#0000FF:"Living Room" \
  GPRINT:LivingRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:LivingRm:MAX:"Max\: %2.1lf" \
  GPRINT:LivingRm:MIN:"Min\: %2.1lf\n" \
  DEF:Bedroom=$RRDFILE:Bedroom:AVERAGE    LINE1:Bedroom#00FF00:"Bedroom" \
  GPRINT:Bedroom:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Bedroom:MAX:"Max\: %2.1lf" \
  GPRINT:Bedroom:MIN:"Min\: %2.1lf\t" \
  DEF:SpareRm=$RRDFILE:SpareRm:AVERAGE    LINE1:SpareRm#FF00FF:"Nursery" \
  GPRINT:SpareRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:SpareRm:MAX:"Max\: %2.1lf" \
  GPRINT:SpareRm:MIN:"Min\: %2.1lf\n" 

#month
rrdtool graph $OUTPATH/month.png --start end-1m --width $WIDTH --height 100 --end now --title "Last Month's Temps" \
  --slope-mode --vertical-label DegC --alt-autoscale-min --alt-autoscale-max \
  DEF:Outside=$RRDFILE:Outside:AVERAGE    LINE1:Outside#000000:"Outside" \
  GPRINT:Outside:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Outside:MAX:"Max\: %2.1lf" \
  GPRINT:Outside:MIN:"Min\: %2.1lf\t" \
  DEF:LivingRm=$RRDFILE:LivingRm:AVERAGE  LINE1:LivingRm#0000FF:"Living Room" \
  GPRINT:LivingRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:LivingRm:MAX:"Max\: %2.1lf" \
  GPRINT:LivingRm:MIN:"Min\: %2.1lf\n" \
  DEF:Bedroom=$RRDFILE:Bedroom:AVERAGE    LINE1:Bedroom#00FF00:"Bedroom" \
  GPRINT:Bedroom:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Bedroom:MAX:"Max\: %2.1lf" \
  GPRINT:Bedroom:MIN:"Min\: %2.1lf\t" \
  DEF:SpareRm=$RRDFILE:SpareRm:AVERAGE    LINE1:SpareRm#FF00FF:"Nursery" \
  GPRINT:SpareRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:SpareRm:MAX:"Max\: %2.1lf" \
  GPRINT:SpareRm:MIN:"Min\: %2.1lf\n" 

#year
rrdtool graph $OUTPATH/year.png --start end-1y --width $WIDTH --height 100 --end now --title "Last Year's Temps" \
  --slope-mode --vertical-label DegC --alt-autoscale-min --alt-autoscale-max \
  DEF:Outside=$RRDFILE:Outside:AVERAGE    LINE1:Outside#000000:"Outside" \
  GPRINT:Outside:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Outside:MAX:"Max\: %2.1lf" \
  GPRINT:Outside:MIN:"Min\: %2.1lf\t" \
  DEF:LivingRm=$RRDFILE:LivingRm:AVERAGE  LINE1:LivingRm#0000FF:"Living Room" \
  GPRINT:LivingRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:LivingRm:MAX:"Max\: %2.1lf" \
  GPRINT:LivingRm:MIN:"Min\: %2.1lf\n" \
  DEF:Bedroom=$RRDFILE:Bedroom:AVERAGE    LINE1:Bedroom#00FF00:"Bedroom" \
  GPRINT:Bedroom:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:Bedroom:MAX:"Max\: %2.1lf" \
  GPRINT:Bedroom:MIN:"Min\: %2.1lf\t" \
  DEF:SpareRm=$RRDFILE:SpareRm:AVERAGE    LINE1:SpareRm#FF00FF:"Nursery" \
  GPRINT:SpareRm:AVERAGE:"Avg\: %2.1lf" \
  GPRINT:SpareRm:MAX:"Max\: %2.1lf" \
  GPRINT:SpareRm:MIN:"Min\: %2.1lf\n" 

# #years power
# rrdtool graph $OUTPATH/power-year.png --start end-1y $CHARTSIZE --end now --title "Year's Power" \
#   --slope-mode --vertical-label Watts --lower-limit 0 --alt-autoscale-max \
#   DEF:Power=$RRDFILE:power:AVERAGE  LINE1:Power#0000FF:"Average" 
# #  DEF:PowerMin=$RRDFILE:power:MIN   \
# #  DEF:PowerMax=$RRDFILE:power:MAX   \
# #  CDEF:PowerRange=PowerMax,PowerMin,- LINE1:PowerMin: AREA:PowerRange#FF000066:"Range":STACK 
# #years temp
# rrdtool graph $OUTPATH/temp-year.png --start end-1y $CHARTSIZE --end now --title "Year's Temperatures" \
#   --slope-mode --vertical-label "Deg C" --alt-autoscale-max \
#   DEF:Temp=$RRDFILE:temp:AVERAGE  LINE1:Temp#FF0000:"Average" 
# #  DEF:TempMin=$RRDFILE:temp:MIN   \
# #  DEF:TempMax=$RRDFILE:temp:MAX   \
# #  CDEF:TempRange=TempMax,TempMin,- LINE1:TempMin: AREA:TempRange#0000FF33:"Range":STACK 
