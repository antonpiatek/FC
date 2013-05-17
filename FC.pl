#!/usr/bin/perl

use strict;
use warnings;

use AnyEvent::MQTT;                                                                                                                                                                                               
use AnyEvent;                                                                                                                                                                                                   

use Data::Dumper;

my $ARDUINO="/dev/ttyACM0";
my $RRD = "/home/anton/arduino/FC/temperatures.rrd";

die "RRD file $RRD not file" unless -e $RRD;

my $mqtt = AnyEvent::MQTT->new();                                                                                                                                                                                

open( my $FH, "<", $ARDUINO) || die "error opening $ARDUINO, $!";
my $processing_temps = 0;

my %temps = ();
while(<$FH>)
{
  chomp $_;

  #skip blank lines
  next if /^\s*$/;
  #skip checking lines
  next if /Checking Sensor \d/;
  
  #    found sensor with address 28CE85BB020000C1 which should be Bedroom 
  if( /found sensor with address \w+ which should be (\w+)/ )
  {
    print "active sensor: $1\n";
    $processing_temps = 1;
  }

  #look for lines like
  # Temp reading Spare Rm: 19.44
  elsif($processing_temps &&  /Temp reading (.+): ([\d\.]+)/ )
  {
    #got temp
    my $room = $1;
    my $temp = sprintf "%2.1f", $2;

    print "temp in room $room is $temp deg c\n"; 
    publishTemperature($room,$temp);

    #store value
    $temps{$room} = $temp;
    #If we have 4, run rrd update and reset values
    #TODO: do this better - if we have one sensor down, we will never got here and not give any errors
    if(keys %temps == 4)
    {
      updateRRD(%temps);
      %temps = ();
    }
  }
  else
  {
    print "W: $_\n";
  }


}

print 'if nothing on serial, perhaps try running "echo -e \'\x0b\' | '."$ARDUINO\n";
print "as the Arduino dev kit does not close serial port properly\n";
print "also, other people talk about setting 'stty -F $ARDUINO cs8 19200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke noflsh -ixon -crtscts'\n";

sub publishTemperature
{
  my $name = shift || die;
  my $temp = shift || die;

  # publish a simple message
  my $cv = $mqtt->publish(message => $temp,
                          topic => "Temperatures/$name");
  $cv->recv; # sent
}


sub updateRRD
{
  my %opts = @_;
  #Currently have 4 readings to store:  LivingRm Bedroom SpareRm Outside
   
  my %temps = (LivingRm=>undef, Bedroom=>undef, SpareRm=>undef,Outside=>undef);

  while( my ($key,$value) = each (%opts) )
  {
    #strip whitespace
    $key =~ s/\s+//g;

    #die? or log and skip?
    die "ERROR: don't know about sensor $key" if ! exists $temps{$key};
    $temps{$key} = $value;
  }

  #check we are not missing values
  while( my ($key,$value) = each (%opts) )
  {
    die "Don't have a temperature for $key" unless defined $value;
  }
  
  #update rrd
  my $cmd = "rrdtool update $RRD N:$temps{LivingRm}:$temps{Bedroom}:$temps{SpareRm}:$temps{Outside}";
  print "running $cmd\n";
  system($cmd);
  die "$!" unless $? == 0;
}
