#!/usr/bin/perl -w

use strict;
use warnings;

use XML::Twig;

my @translation = ( 'fr', 'de' );

sub checkAttr {
    my $origFile = $_->att("href");

    return unless $origFile;
    return unless $origFile =~ /\.dita$/;

    foreach my $lang (@translation) {
	next if -f "$lang/$origFile";
	
	open DEST, ">$lang/$origFile" or die;

	print DEST "<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE topic PUBLIC \"-//OASIS//DTD DITA Topic//EN\" \"../../dtd/topic.dtd\" []>
<topic id=\"todo\" xml:lang=\"en-us\">
  <title>TODO untranslated</title>
  <shortdesc>TODO untranslated</shortdesc>
  <body>
    <p>TODO untranslated</p>
  </body>
</topic>
\n";

    }
}


my $twig=XML::Twig->new(twig_handlers => { _all_ => \&checkAttr });
$twig->parsefile("en/fusioninventory.ditamap");
