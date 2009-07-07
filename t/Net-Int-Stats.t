# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Net-Int-Stats.t'

#########################

use Test::More tests => 5;

# test if linux platform
ok($^O =~ /linux/, 'OS check') || BAIL_OUT("Operating system is $^O instead of linux!");

# does /sbin/ifconfig exist?
ok(-e '/sbin/ifconfig', '/sbin/ifconfig test') || BAIL_OUT('Does /sbin/ifconfig exist?'); 

# load module
BEGIN { use_ok('Net::Int::Stats') };

# check object class
my $obj = Net::Int::Stats->new();
isa_ok($obj, 'Net::Int::Stats');

# check method interface
my @methods = qw(rx_packets rx_errors rx_dropped rx_overruns rx_frame
		 tx_packets tx_errors tx_dropped tx_overruns tx_carrier
		 collisions txqueuelen);
can_ok($obj, @methods);

