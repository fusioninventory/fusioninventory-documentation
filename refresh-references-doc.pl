#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Path qw(make_path);
use Pod::Markdown;
use Git::Repository;

my $tmpDir = "/home/goneri/fusioninventory/tmp/wikigit";

my @repoList = (
    {

        name => 'agent',
        url =>
          'git+ssh://forge.fusioninventory.org/git/fusioninventory/agent.git',
        branches => [
            {
                serie  => '2.1.x',
                branch => '2.1.x',
                status => 'oldstable'
            },
            {
                serie  => '2.2.x',
                branch => '2.2.x',
                status => 'stable'
            },
            {
                'serie'  => '2.3.x',
                'branch' => '2.3.x',
                'status' => 'dev',
            },
            {
                'serie'  => '3.0.x',
                'branch' => 'master',
                'status' => 'dev'
            },
        ],
        files => [
            'fusioninventory-agent', 'fusioninventory-injector',
            'fusioninventory-inventory'
          ]

    },
    {

        name => 'agent-task-esx',
        url =>
          'git+ssh://forge.fusioninventory.org/git/fusioninventory/agent-task-esx.git',
        branches => [
            {
                serie  => '2.x',
                branch => 'master',
                status => 'stable'
            }
        ],
        files => [
            'fusioninventory-esx'
        ]

    },
    {

        name => 'agent-task-network',
        url =>
          'git+ssh://forge.fusioninventory.org/git/fusioninventory/agent-task-network.git',
        branches => [
            {
                serie  => '1.0.x',
                branch => 'master',
                status => 'stable'
            }
        ],
        files => [
            'fusioninventory-netdiscovery', 'fusioninventory-netinventory'
          ]

    },

);


my $indexContent = "# Reference documentation\n";

my $wiki = Git::Repository->new( work_tree => '.' );
eval { $wiki->run('rm', '-rf', "documentation/references") };

foreach my $repo (@repoList) {
    my $localDir = sprintf( "%s/%s", $tmpDir, $repo->{name} );

    if ( !-d $localDir && !make_path($localDir) ) {
        die "mkdir failed\n";
    }

    if ( !-d "$localDir/.git" ) {
        Git::Repository->run( 'clone' => $repo->{url}, $localDir );
    }
    my $r = Git::Repository->new( work_tree => $localDir );
    $r->run( 'fetch', 'origin' );

    foreach my $file ( @{ $repo->{files} } ) {

        $indexContent .= "\n## $file\n\n";

        foreach my $branch ( @{ $repo->{branches} } ) {

            my $content =
              eval{ $r->run( 'show', 'origin/' . $branch->{branch} . ':' . $file ) };


            open TMP, ">$localDir/tmpfile" or die;
            print TMP $content;
            close TMP;

            my $mdwnFile = sprintf("documentation/references/%s/%s/%s", $repo->{name}, $branch->{serie}, $file);
            print $mdwnFile. "\n";

            next unless $content;

            my $parser = Pod::Markdown->new;
            $parser->parse_from_file("$localDir/tmpfile");
            make_path( dirname( $mdwnFile . '.mdwn' ) );
            open OUT, ">" . $mdwnFile . '.mdwn' or die "$!";

            if ($branch->{status} !~ /stable/) {
                print OUT '[[!template  id=warning text="The '.$branch->{serie}.' serie is still in developpement."]]'."\n\n";
            } elsif ($branch->{status} eq 'oldstable') {
                print OUT '[[!template  id=info text="The '.$branch->{serie}.' is not maintained anymore. You should consider an upgrade to the last stable release."]]'."\n\n";
            }
            print OUT $parser->as_markdown;
            close OUT;
            $wiki->run('add', $mdwnFile . '.mdwn');
            $indexContent .= "* [[".$branch->{serie}." (".$branch->{status}.")|$mdwnFile]]\n";

        }

    }

}

open INDEX, ">documentation/references.mdwn" or die;
print INDEX $indexContent;
close INDEX;
$wiki->run('add', "documentation/references.mdwn");

