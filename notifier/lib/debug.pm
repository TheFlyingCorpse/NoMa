#!/usr/bin/perl

# COPYRIGHT:
#
# This software is Copyright (c) 2007-2009 NETWAYS GmbH, Christian Doebler
#                 some parts (c) 2009      NETWAYS GmbH, William Preston
#                                <support@netways.de>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:GPL2
# see noma_daemon.pl in parent directory for full details.
# Please do not distribute without the above file!


sub debugArray
{
    my @array  = @_;
    my $output = '';
    for my $data (@array)
    {
        $output .= "  $data\n";
    }
    return $output;
}

sub debugHash
{
    my %hash   = @_;
    my $empty  = 1;
    my $output = '';
    while ( my ( $key, $value ) = each %hash )
    {
        $output .= "$key\n";
        while ( my ( $innerKey, $innerValue ) = each %{ $hash{$key} } )
        {
            $innerKey   = '_NULL_' if ( !defined($innerKey) );
            $innerValue = '_NULL_' if ( !defined($innerValue) );
            $output .= "     $innerKey - $innerValue\n";
        }
        $empty = 0 if ( $empty == 1 );
    }
    $output .= "EMPTY!\n" if ( $empty == 1 );
    return $output;
}

sub debugHashUsers
{
    my %hash   = @_;
    my $output = '';
    my @users = ();
    while ( my ( $key, $value ) = each %hash )
    {
        push @users, $hash{$key}{'username'}.' ('. $hash{$key}{'username'}.')';
    }
    $output = join(',', @users);
    $output = "EMPTY!\n" if ( $output eq '' );
    return $output;
}

sub debug
{

    my ($msg, $severity) = @_;
    my $debug = $conf->{debug}->{logging};
    my $debug_file = $conf->{debug}->{file};
    my $caller = (caller(1))[3];
    $caller = 'main' unless defined($caller);

    if ( defined($debug) && $debug && ($debug ge $severity) )
    {

        $msg =~ s/\s*\n\s*/ /g;
        $msg .= "\n";

        if ( defined($debug_file) && $debug_file ne '' )
        {

            open( DEBUGFILE, ">> $debug_file" );
            print DEBUGFILE '[' . localtime() . '] ' . $caller . ': ' . $msg;
            close(DEBUGFILE);

        } else
        {
            print  '[' . localtime() . '] ' . $caller . ': ' . $msg;

        }

    }

}







1;
