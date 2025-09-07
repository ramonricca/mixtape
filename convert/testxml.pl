#!/usr/bin/perl
use XML::XSLT;
use Data::Dumper;
use strict;


my $xslt = XML::XSLT->new ("/home/rricca/sounds/xsd/3.1/musicxml-3.1/schema/timepart.xsl", warnings => 1);
$xslt->transform ("/home/rricca/sounds/rondo2/score.xml");
print $xslt->toString;
$xslt->dispose();