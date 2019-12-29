#@brief		Controlling a KMtronix usb relay
#@author	Helge Klug
#@copyright	Copyright (c) 2019 Helge Klug
#@version	1.00
#@note		Just tested with a two channels usb relay (Product Code: U2CRD)


use strict;
use Device::SerialPort qw( :PARAM :STAT 0.07 );


my	$SerialPort		= $ARGV[0];
my	$Channel		= int($ARGV[1]);
my	$Command		= lc($ARGV[2]);
my	$CommandChannel	= sprintf("0x%02X", $Channel);
my	$SerialCommand;


my $NumArgs = $#ARGV + 1;

if ($NumArgs != 3)
{
    die "\nUsage:UsbRelay.pl <SerialPort> <Channel> <command (ON, OF, STATUS)>\n";
}

if ( $Command ne lc('ON') &&  $Command ne lc('OFF') &&  $Command ne lc('STATUS')  )
{
     die "\n Command '".uc($Command)."' is not supported!";
}

if ( $Channel > 255 )
{
    die "\n A maximum of 255 channels are supported!"
}

if ( $Channel < 1 )
{
    die "\n Channels must be greater than 0!"
}

# Config serial port
my $RelayObject	=Device::SerialPort->new($SerialPort);
   $RelayObject->baudrate(9600);
   $RelayObject->parity('none');
   $RelayObject->databits(8);
   $RelayObject->stopbits(1);
   $RelayObject->write_settings;


# Open serial port
open(USB_RELAY, "+>$SerialPort");

if	( $Command eq lc('ON')  )
{
    $RelayObject->write( pack 'C' x 3, 0xFF, $Channel, 0x01 );
    print "\nSwitch Port ".$Channel." to ON";
}
elsif	( $Command eq lc('OFF') )
{
    $RelayObject->write( pack  'C' x 3, 0xFF, $Channel, 0x00);
    print "\nSwitch Port ".$Channel." to OFF";
}

# request status
$RelayObject->write( pack 'C' x 3, 0xFF, $Channel, 0x03);

# give some time to perform request
sleep(1);
    
my @StatusArray	= unpack( 'H2' x 3, $RelayObject->read(3) );
my $Status	= $StatusArray[2];

if ( $Status eq '00')
{
    $Status = 'OFF';
}
elsif ( $Status eq '01')
{
    $Status = 'ON'
}
else
{
    $Status = 'UNKOWN'
}


print("\nStatus Port ".$Channel." is " .$Status );
print( "\n\n");

# Close port
$RelayObject->close;
undef $RelayObject;

exit  $Status;