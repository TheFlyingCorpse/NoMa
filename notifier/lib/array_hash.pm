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

sub removeHashEntryDuplicates
{

    my ($inHash) = @_;

    my %outHash;
    my $found;
    my $countNew = 0;

    while ( my ($entry) = each( %{$inHash} ) )
    {

        $found = 0;

        while ( my ($entryOut) = each(%outHash) )
        {

            $found++
              if (
                $inHash->{$entry}->{username} eq $outHash{$entryOut}->{username}
                && $inHash->{$entry}->{method} eq $outHash{$entryOut}->{method}
                && $inHash->{$entry}->{let_notifier_handle} eq
                $outHash{$entryOut}->{let_notifier_handle} );

            last if ( $found != 0 );

        }

        if ( $found == 0 )
        {

            # store entry if it has not been found, yet
            $outHash{$countNew} = $inHash->{$entry};

            $countNew++;

        }

    }

    return %outHash;

}


sub mergeHashes
{

    my ( $hash1, $hash2 ) = @_;

    my %mergedHash;
    my $cnt = 0;

    # add hash1 to mergedHash
    while ( my ($data) = each( %{$hash1} ) )
    {
        $mergedHash{ $cnt++ } = $hash1->{$data}
          if ( defined( $hash1->{$data}->{username} ) );
    }

    # add hash2 to mergedHash
    while ( my ($data) = each( %{$hash2} ) )
    {
        $mergedHash{ $cnt++ } = $hash2->{$data}
          if ( defined( $hash2->{$data}->{username} ) );
    }

    return %mergedHash;

}

sub hash2arr
{

    my (%hash) = @_;
    my @array;

    while ( my ($data) = each(%hash) )
    {
        push( @array, $hash{$data} );
    }

    return @array;

}

sub getArrayOfNums
{

    my ( $input_str, $notificationCounter ) = @_;
    my @ret_arr = ();
    my @tmp_arr1;
    my @tmp_arr2;
    my $cnt;
    my $check_max = 0;

    #return () unless (defined($input_str));

    @tmp_arr1 = split( /[;,]/, $input_str );

    for my $current_element (@tmp_arr1)
    {

        @tmp_arr2 = split( '-', $current_element );

        if ( defined( $tmp_arr2[1] ) )
        {

            my $count = @tmp_arr2;

            if ( $count == 1 )
            {
                if ( $tmp_arr2[0] > $notificationCounter )
                {
                    pushUnique( \@ret_arr, $tmp_arr2[0] );
                    $check_max = $tmp_arr2[0];
                } elsif ( $tmp_arr2[0] < $notificationCounter )
                {
                    pushUnique( \@ret_arr, $notificationCounter );
                    $check_max = $notificationCounter;
                } else
                {
                    pushUnique( \@ret_arr, $notificationCounter );
                    $check_max = $notificationCounter + 1;
                    pushUnique( \@ret_arr, $check_max );
                }
            } else
            {
                my $cnt;
                for ( $cnt = $tmp_arr2[0] ; $cnt <= $tmp_arr2[1] ; $cnt++ )
                {
                    pushUnique( \@ret_arr, $cnt );
                }
                $check_max = $cnt - 1;
            }

        } else
        {

            pushUnique( \@ret_arr, $tmp_arr2[0] );
            $check_max = $tmp_arr2[0];

        }

        $max_notificationCounter = $check_max
          if ( $max_notificationCounter < $check_max );

    }

    return @ret_arr;

}


sub getMaxFromArray
{

    my ($arr) = @_;

    my $max;
    my $current;
    my $first = 1;

    foreach $current (@$arr)
    {
        if ($first)
        {
            $max = $current;
        } else
        {
            $max = $current if ( $max < $current );
        }
    }

    return $max;

}

sub arrayToHash
{

    my ($in) = @_;
    my %out;
    my $counter = 0;

    foreach my $current (@$in)
    {
        $out{ $counter++ } = $current;
    }

    return %out;

}

1;
