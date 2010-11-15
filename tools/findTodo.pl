#!/usr/bin/perl

use strict;
use warnings;

use POSIX qw(strftime);

my $targetLang = $_[0];

my @lang = qw/fr en de/;

sub getDitaFiles {
    my $dir = "fr/fusioninventory";
    opendir(my $dh, $dir) || die "can't opendir $dir: $!";
    my @ditas = grep { /\.dita$/ && -f "$dir/$_" } readdir($dh);
    closedir $dh;

    return sort @ditas;
}

sub analyseStatus {
    my ($ditaFile, %status) = @_;

    my $max = "";
    my $refLang;
    foreach my $l (@lang) {
	if (defined($status{$l}) && $status{$l} gt $max) {
	    $max = $status{$l};
	    $refLang = $l;
	}
    }

    my @error;
    foreach my $l (@lang) {
	next if ($targetLang && $l ne $targetLang);
	if (!defined($status{$l})) {
	    push @error, "[$l] No stamp";
	} elsif ($status{$l} ne $max) {
	    push @error, "[$l] Please sync changes from $l";
	}
    }

    print "\n".$ditaFile."\n" if @error;
    print "  $_\n" foreach @error;
}


foreach my $ditaFile (getDitaFiles) {
    my %status;

    foreach my $l (@lang) {
	open FD, "<$l/fusioninventory/$ditaFile" or die;
	my $content;
	{
	    $/=undef;
	    $content = <FD>;
	    if ($content =~ /<!-- LAST_UPDATE=(\d{4}-\d{1,2}-\d{1,2}) (\d{1,2}:\d{1,2}:\d{1,2}) -->/) {
		$status{$l} = "$1 $2";
	    }
	}
	close FD;
    }

    analyseStatus($ditaFile, %status);
}
