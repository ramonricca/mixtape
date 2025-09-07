#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use strict;

my $fn = $ARGV[0];
die "Use xml filename as argument." if !$fn;

my ($z, $ref, $xml);
if ( $fn =~ /\.xml$/) {
	$ref = XMLin($fn);
}
else {
    die "score should have .xml extension.";
}

print Dumper $ref;

my ($beat, $beat_type, $divisions, $duration);
if (exists $ref->{'part'}->{'measure'}->{'attributes'}) {
    $beat = $ref->{'part'}->{'measure'}->{'attributes'}->{'time'}->{'beat'};
    $beat_type = $ref->{'part'}->{'measure'}->{'attributes'}->{'time'}->{'beat-type'};
    $divisions = $ref->{'part'}->{'measure'}->{'attributes'}->{'divisions'};
    $duration = $divisions * $beat;
}

