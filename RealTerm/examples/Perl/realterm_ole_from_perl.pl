#! perl

=for docs

Here we have an example of are controlling RealTerm 
as an out-of-process OLE server to capture serial data 
into a file for a particular duration.

=cut

use strict;
use warnings;
use Win32;
use Win32::OLE;
use Win32::OLE::Const 'Realterm Library';
# Die on OLE errors...
$Win32::OLE::Warn = 3;
use Log::TraceMessages qw(t d);
$Log::TraceMessages::On = 1;
# Hot file handle magic...
select( ( select(STDERR), $| = 1 )[0] );
select( ( select(STDOUT), $| = 1 )[0] );
# Use the directory where the script resides...
my ( $exedir, $exefile ) = Win32::GetFullPathName($0);
my $capfile  = $exedir . 'realterm_data.txt';
my $duration = 3600;
my $port     = 1;
my $baud     = 9600;
t "Capture file is '$capfile'";
t "Starting OLE server...";
my $thing = Win32::OLE->new('realterm.realtermintf');
$thing->{Visible}        = 0;
$thing->{TrayIconActive} = 0;
#~ $thing->{caption}        = 'Automated serial data capture - do not touch';
$thing->{baud}        = $baud;
$thing->{Port}        = $port;
$thing->{CaptureFile} = $capfile;
#~ $thing->{CaptureEnd} = 20;
#~ $thing->{CaptureEndUnits} = Secs;
$thing->{PortOpen} = 1;
t "Starting capture for $duration seconds...";
$thing->StartCapture();
sleep $duration;
$thing->StopCapture();
t "Finished capture.";
$thing->{PortOpen} = 0;
# Finished with OLE server - undefine it...
undef $thing;
# OK, we should now have some results in the capfile...
if ( not open CF, "< $capfile" ) {
    die "Failed to open '$capfile': $!";
}
while (<CF>) {
    chomp;
    t "$.:'$_'";
}
close CF;
__END__

