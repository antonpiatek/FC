#!/usr/bin/python
import re
import time
import subprocess
import datetime
import smtplib
from email.mime.text import MIMEText

import mosquitto

"""
if nothing on serial, perhaps try running "echo -e \'\x0b\' | '."$ARDUINO\n";
as the Arduino dev kit does not close serial port properly\n";
also, other people talk about setting 'stty -F $ARDUINO cs8 19200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke noflsh -ixon -crtscts'\n";
"""

ARDUINO = "/dev/ttyACM0"
RRD = "/home/anton/arduino/FC/temperatures.rrd"
EXPECTED_TEMPS = ["Bedroom","LivingRm","Nursery","Outside"]



def on_publish(obj,mid):
    #TODO: check for error message?
    print "Message ",mid," published"
    print obj



def on_connect(obj,rc):
    if rc != 0:
        print "Error connecting, rc",rc
        raise Exception()



def publish_temperature(mqttclient, name, temp):
    topic = "Temperatures/"+name
    print "publishing to '"+topic+"'"+" "+temp
    mqttclient.publish(topic,temp, 1)
    rc = mqttclient.loop()
    if rc != 0:
        print "MQTTloop failed",rc
        print mosquitto.get_errno()
        raise Exception()



def save_temps_to_rrd(temps):
    print "saving temps to rrd"
    if sorted(temps.keys()) != sorted(EXPECTED_TEMPS):
        print "wrong set of temp values", sorted(temps.keys()), "not equal to", sorted(EXPECTED_TEMPS) 
        raise Exception()
    cmd = ("rrdtool","update", RRD, "N:"+temps["LivingRm"]+":"+temps["Bedroom"] \
          +":"+temps["Nursery"]+":"+temps["Outside"] )
#    print cmd
    subprocess.check_call(cmd)


    
def main():
  mqttclient = mosquitto.Mosquitto("arduino")
  mqttclient.log_init(mosquitto.MOSQ_LOG_ERR|mosquitto.MOSQ_LOG_WARNING,mosquitto.MOSQ_LOG_STDOUT)
  mqttclient.on_connect = on_connect
  mqttclient.connect("127.0.0.1")
#  mqttclient.on_publish = on_publish
  mqttclient.loop()

  print "opening arduino on "+ARDUINO
  fh = open(ARDUINO, 'r')

  temps = {}

  while 1:
      line = fh.readline()

      if not line:
          break

      line.rstrip()

      if re.match(r"^\s*$",line):
          continue
      if re.match(r"Checking Sensor \d",line):
          continue
      c = re.match(r"(\d) temp sensors found",line)
      if c:
          print "arduino reports ",c.group(1),"sensors"
          if int(c.group(1)) != len(EXPECTED_TEMPS):
              print "Expected",len(EXPECTED_TEMPS),"sensors on arduino, only found",c.group(1), "aborting!"
              raise Exception()
          continue

     #    found sensor with address 28CE85BB020000C1 which should be Bedroom 
      m1 = re.match(r"found sensor with address \w+ which should be (\w+)", line)
      m2 = re.match(r"Temp reading (.+): ([\-]?[\d\.]+)", line)
      if m1:
          print "active sensor "+m1.group(1)
      elif m2:
          name = m2.group(1).rstrip()
          temp = m2.group(2).rstrip()

          temps[name] = temp
          publish_temperature(mqttclient, m2.group(1),m2.group(2))
      else: 
          print "W:"+ line
      
      if len(temps) == 4:
          save_temps_to_rrd(temps)
          temps = {}
  fh.close



# try/catch. Abort if main loop fails 3 times in a row
failCount = 0
lastAttempt = datetime.datetime.now()
while failCount < 3:
  try:
    lastAttempt = datetime.datetime.now()
    print "restarting"
    main();
  except Exception as e:
    #If we ran longer than 60 seconds, consider it ok and reset fail counter
    if (datetime.datetime.now() - lastAttempt).seconds > 60:
      failCount = 0
    #If we didn't, increase counter so we abort if we we fail too often
    else:
      failCount = failCount + 1
    print type(e)     # the exception instance
    print e.args      # arguments stored in .args
    print e           # __str__ allows args to printed directly
    time.sleep(5)

print "Too many failures, exiting"
msg = MIMEText('Arduino reader had too many errors')
# Open a plain text file for reading. For this example, assume that # the text file contains only ASCII characters. fp = open(textfile, 'rb') # Create a text/plain message msg = MIMEText(fp.read()) fp.close()

# me == the sender's email address # you == the recipient's email address 
msg['Subject'] = 'Arduino reader died'
msg['From'] = 'anton@flat.piatek.co.uk' 
msg['To'] = 'anton'

# Send the message via our own SMTP server, but don't include the 
# envelope header. 
s = smtplib.SMTP('localhost') 
s.sendmail(me, [you], msg.as_string()) 
s.quit()
