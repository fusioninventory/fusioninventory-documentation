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

sub createEmptyDita {
    my ($ditaFile) = @_;

    open DITA, ">$ditaFile" or die;
    print DITA '<?xml version=\'1.0\' encoding=\'UTF-8\'?>
<!-- LAST_UPDATE=1970-01-01 00:00:00 -->
<!DOCTYPE topic PUBLIC "-//OASIS//DTD DITA Topic//EN" "../../dtd/topic.dtd" []>
<topic id="toto" xml:lang="en-en">
  <title>TODO</title>
  <shortdesc>TODO</shortdesc>
  <body>
  <p>TODO</p>
  </body>
</topic>';
    close DITA;

}


my @newFiles;
foreach my $ditaFile (getDitaFiles) {
    my %status;
    foreach my $l (@lang) {
	if (! -f "$l/fusioninventory/$ditaFile") {
	    createEmptyDita("$l/fusioninventory/$ditaFile");
	    push @newFiles, "$l/fusioninventory/$ditaFile";
	}

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

if (@newFiles) {
    print "\nNew empty file generated.:\n";
    print "  $_\n" foreach @newFiles;
    print "DONT FORGET TO 'git add' them!!!\n";
}
