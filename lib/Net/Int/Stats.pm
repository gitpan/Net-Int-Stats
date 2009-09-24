package Net::Int::Stats;

our $VERSION = '2.01';

use strict;
use warnings;

# store ifconfig output
my @interface = `/sbin/ifconfig`;
# hash of hashes
# key1 - interface, key2 - type ex: rx_packets, values ex: 'packets:12345'
my %interfaces;
# tmp array to store string tokens
my @tmp;
# interface name
my $key1;
# key2
my @key2;

# loop through each line of ifconfig output
foreach (@interface){
	# skip if blank
    next if /^$/;

	# get interface
	# if not space
    if (!/^\s/){
		# extract values
		extract($_);
		# store first token of interface name
        $key1 = shift(@tmp);
    }

	# get RX, TX, collisions and txqueuelen values
	# look for 'RX' or 'TX' or 'collisions' text
    if (/RX packets/ || /TX packets/ || /collisions/){
		# key2 values
        @key2 = qw(rx_packets rx_errors rx_dropped rx_overruns rx_frame) if (/RX packets/);
		@key2 = qw(tx_packets tx_errors tx_dropped tx_overruns tx_carrier) if (/TX packets/);
		@key2 = qw(collisions txqueuelen) if (/collisions/);
		# extract values
		extract($_);
		# shift first token of 'RX' or 'TX'
        shift(@tmp) if (/RX packets/ || /TX packets/);
		# build hash
		build();
	}
}

# extract values
sub extract {
	my $line = shift;
	# remove spaces
    $line =~ s/^\s+//;
    # store tokens split on spaces
    @tmp = split (/\s/, $line);
}

# build values hash
sub build {
	my $i = 0;
    for (@key2){
    	$interfaces{$key1}{$_} = $tmp[$i];
        $i++;
    }
}

# validate interface name
sub validate {
	# interface name
    my $int = shift;
	# terminate program if specified interface name is not in ifconfig output
    die "specified interface $int not listed in ifconfig!\n" if !(grep(/$int/, keys %interfaces));
}

# create new Net::Int::Stats object
sub new {
	my $class = shift;
    my $self  = {};

    bless($self, $class);
    $self->{VALUE} = '';

    return $self;
}

# get specific ifconfig value for specific interface
sub value {
    my $self = shift;
    my $int  = shift;
    my $type = shift;

	# validate if supplied interface is present
	validate($int);

	$self->{VALUES} = $interfaces{$int}{$type};

    return $self->{VALUES};
}

1;

__END__

=head1 NAME

Net::Int::Stats - Reports specific ifconfig values for a network interface

=head1 SYNOPSIS

  use Net::Int::Stats;

  my $get = Net::Int::Stats->new();

  # get value for specific interface
  my $int     = 'eth0';
  my $stat    = 'rx_packets';
  my $packets = $get->rx_packets($int, $stat);

=head1 DESCRIPTION

This module provides various statistics generated from the ifconfig command for specific interfaces. 
RX values consist of packets, errors, dropped, overruns, and frame. TX values consist of packets, 
errors, dropped, overruns, and carrier. In addition, collisions and txqueuelen are reported. Values 
are in the format of type:n - ex 'packets:123456'.

=head1 METHODS

Use this one method to get specific values which requires two arguments: B<value()>.
Ex: $packets = $get->value($int, 'rx_packets');

The first argument is the interface and the second is the type value to extract.

RX values - rx_packets, rx_errors, rx_dropped, rx_overruns, rx_frame

TX values - tx_packets, tx_errors, tx_dropped, tx_overruns, tx_carrier

Miscellaneous values - collisions, txqueuelen

=head1 DEPENDENCIES

This module is platform dependent. It uses the linux version
of /sbin/ifconfig. Other platforms such as the windows equivalent
of ipconfig, mac osx, and other versions of unix are not supported. 
This is due to the fact that each platform generates and displays
different information in different formats of ifconfig results.
The linux version is used over the other platforms because of the 
amount of data the default command outputs.  

=head1 SEE ALSO

linux command /sbin/ifconfig

=head1 NOTES

ifconfig output contains more information than the values that are
extracted in this module. More values can be added if there are any 
requests to do so.   

=head1 AUTHOR

Bruce Burch <bcb12001@yahoo.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Bruce Burch

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
