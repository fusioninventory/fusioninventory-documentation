#!/usr/bin/perl

use strict;
use warnings;

use POSIX qw(strftime);

use Data::Dumper;

my $mainLanguage = "fr";

my $arg = $ARGV[0];

sub updateFile {
    my ($file) = @_;

    print "update $file\n";

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
}

if ($arg && $arg =~ /^-\d+$/) {
    foreach (`git log --reverse --name-only $arg 2>&1`) {
	next if /^commit /;
	next if /^\S+:\s/;
	next if /^\s/;

	if (/^(\w{2})\/(\S+.*\S+\.dita)/) {
	    next unless $mainLanguage eq $1;
	    updateFile("$1/$2");
	}
    }
} elsif ($arg) {
    updateFile($arg);
} else {
    print STDERR "Flag a file as being the last major version.\n";
    print STDERR "Usage: $0 [filename | -1]\n";
    print STDERR "  filename is an DITA XML file\n";
    print STDERR "  -1 is the number or git revision to flag as major revision. The tool will use git log to get the list of the files.\n";
}


