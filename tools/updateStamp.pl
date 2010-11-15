#!/usr/bin/perl

use strict;
use warnings;

use POSIX qw(strftime);

use Data::Dumper;

my $file = $ARGV[0];

print $file."\n";

open FD, "<$file" or die;
my $content;
{
    $/=undef;
    $content = <FD>;
    my $now_string = strftime "%Y-%m-%e %H:%M:%S", gmtime;
    $content =~ s/<!--.*-->(\n|)/<!-- LAST_UPDATE=$now_string -->\n/s;
}
close FD;

open FD, ">$file" or die;
print FD $content;
close FD;
