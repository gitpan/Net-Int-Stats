package Net::Int::Stats;

our $VERSION = '1.00';

use strict;
use warnings;

# store ifconfig output
my @interface = `/sbin/ifconfig`;
# RX key
my $rx        = 'RX';
# TX key
my $tx        = 'TX';
# key for collisions and txqueuelen
my $coll      = 'collisions';
# hash of hash of arrays
# key1 - interface, key2 - type ex: 'RX', list - values ex: 'packets:12345'
my %interfaces;
# tmp array to store string tokens
my @tmp;
# interface name
my $key1;
# type - ex: 'TX'
my $key2;

# loop through each line of ifconfig output
foreach (@interface){
	# skip if blank
        next if /^$/;

	# if not space
        if (!/^\s/){
		# remove spaces
                $_    =~ s/^\s+//;
		# store tokens split on spaces
                @tmp  = split (/\s/, $_);
		# store first token of interface name
                $key1 = shift(@tmp);
        }

	# look for 'RX' or 'TX' text
        if (/RX packets/ || /TX packets/){
		# remove spaces
                $_    =~ s/^\s+//;
		# store tokens split on spaces
                @tmp  = split (/\s/, $_);
		# store first token of RX or TX
                $key2 = shift(@tmp);
		# build hash
                push(@{$interfaces{$key1}{$key2}}, @tmp);
        }

	# look for 'collisions' text
        if (/collisions/){
		# remove spaces
                $_    =~ s/^\s+//;
		# store tokens split on spaces
                @tmp  = split (/\s/, $_);
		# assign 'collisions' as $key2
                $key2 = 'collisions';
		# build hash
                push(@{$interfaces{$key1}{$key2}}, @tmp);
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

	# initialize object instances
        $self->_init();

        return $self;
}

# initialize object instances
sub _init {
        my $self         = shift;
	# first method list
        my @method_list1 = qw(RX_PACKETS RX_ERRORS RX_DROPPED RX_OVERRUNS RX_FRAME
                              TX_PACKETS TX_ERRORS TX_DROPPED TX_OVERRUNS TX_CARRIER);
	# second method list
        my @method_list2 = qw(COLLISIONS TXQUEUELEN);

	# intialize first method list
        foreach (@method_list1){
                $self->{$_} = '';
        }

	# initialize second method list
        foreach (@method_list2){
                $self->{$_} = '';
        }
}

# The methods all follow the same format: 
# 1. The interface name is passed and stored in $int
# 2. $int is validated for a match against ifconfig output
# 3. The object instance is set using $int
# 4. The value is returned

# get rx packets
sub rx_packets {
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{RX_PACKETS} = $interfaces{$int}{$rx}[0];
        return $self->{RX_PACKETS};
}

# get rx errors
sub rx_errors{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{RX_ERRORS} = $interfaces{$int}{$rx}[1];
        return $self->{RX_ERRORS};
}

# get rx dropped
sub rx_dropped{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{RX_DROPPED} = $interfaces{$int}{$rx}[2];
        return $self->{RX_DROPPED};
}

# get rx overruns
sub rx_overruns{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{RX_OVERRUNS} = $interfaces{$int}{$rx}[3];
        return $self->{RX_OVERRUNS};
}

# get rx frame
sub rx_frame{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{RX_FRAME} = $interfaces{$int}{$rx}[4];
        return $self->{RX_FRAME};
}

# get tx packets
sub tx_packets{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{TX_PACKETS} = $interfaces{$int}{$tx}[0];
        return $self->{TX_PACKETS};
}

# get tx errors
sub tx_errors{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{TX_ERRORS} = $interfaces{$int}{$tx}[1];
        return $self->{TX_ERRORS};
}

# get tx dropped
sub tx_dropped{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{TX_DROPPED} = $interfaces{$int}{$tx}[2];
        return $self->{TX_DROPPED};
}

# get tx overruns
sub tx_overruns{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{TX_OVERRUNS} = $interfaces{$int}{$tx}[3];
        return $self->{TX_OVERRUNS};
}

# get tx carrier
sub tx_carrier{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{TX_CARRIER} = $interfaces{$int}{$tx}[4];
        return $self->{TX_CARRIER};
}

# get collisions
sub collisions{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{COLLISIONS} = $interfaces{$int}{$coll}[0];
        return $self->{COLLISIONS};
}

# get txqueuelen
sub txqueuelen{
        my $self = shift;
        my $int  = shift;
	validate($int);
        $self->{TXQUEUELEN} = $interfaces{$int}{$coll}[1];
        return $self->{TXQUEUELEN};
}

1;

__END__

=head1 NAME

Net::Int::Stats - Reports specific ifconfig values for a network interface

=head1 SYNOPSIS

  use Net::Int::Stats;

  my $get     = Net::Int::Stats->new();

  # get value for specific interface
  # ex: $int  = 'eth0';
  my $packets = $get->rx_packets($int);

=head1 DESCRIPTION

This module provides various statistics generated from the ifconfig command for specific interfaces. 
RX values consist of packets, errors, dropped, overrruns, and frame. TX values consist of packets, 
errors, dropped, overruns, and carrier. In addition, collisions and txqueuelen are reported. Values 
are in the format of type:n - ex 'packets:123456'.

=head2 METHODS

Use these methods to get specific values.
Ex: $value = $get->rx_packets($int);

rx_packets()
rx_errors()
rx_dropped()
rx_overruns()
rx_frame()
tx_packets()
trx_errors()
tx_dropped()
tx_overruns()
tx_carrier()
collisions()
txqueuelen()

=head1 DEPENDENCIES

This module is platform dependent. It uses the linux version
of /sbin/ifconfig. Other platforms such as the windows equivalent
of ipconfig, mac osx, and other versions of unix are not supported. 
This is due the fact that each platform generates and displays
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
