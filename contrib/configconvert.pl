#!/usr/bin/perl
# COPYRIGHT:
#  
# This software is Copyright (c) 2011 NETWAYS GmbH
#                                       <support@netways.de>
#                                  and
#                                     Rune "TheFlyingCorpse" Darrud
#                                       <theflyingcorpse@gmail.com>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from http://www.fsf.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.fsf.org.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to NETWAYS GmbH.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# this Software, to NETWAYS GmbH, you confirm that
# you are the copyright holder for those contributions and you grant
# NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.

#
# Use this script to convert your existing noma_conf.pm to NoMa.yaml, the new configuration file format introduced with NoMa 2.0
#

# Copy noma_conf.pm to the same directory as this file, execute and copy the output file to the new location.


# Output file
$file = '/tmp/NoMa.yaml';

use lib "$FindBin::Bin"; # Find all libraries...
use noma_conf; # Load old noma_conf.pm library.
use YAML::Syck;
our $conf  = conf();

# Set this for interoperability with other YAML/Syck bindings:
# e.g. Load('Yes') becomes 1 and Load('No') becomes ''.
$YAML::Syck::ImplicitTyping = 1;

# Dump to file.
DumpFile($file, $conf);

print('New config saved to '.$file.'\n');

