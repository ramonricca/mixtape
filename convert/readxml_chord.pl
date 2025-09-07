#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use strict;

my $fn = $ARGV[0];
die "Use xml filename as argument." if !$fn;

my $PRINTOUT = 0;
my $notemap = {
    C => 0,
    CsDb => 1,
    D => 2,
    DsEb => 3,
    E => 4,
    F => 5,
    FsGb => 6,
    G => 7,
    GsAb => 8,
    A => 9,
    AsBb => 10,
    B => 11,
};
my $ref = XMLin($fn);

print Dumper $ref;
exit();
my @score;

foreach my $measure (@{$ref->{'part'}->{'measure'}}) {
#foreach my $att (qw|0 1 2 3|) {
#	print Dumper $measure->{'chord'};
	my $initvol = 1;
	#if (($measure->{'number'} >= 9) && ($measure->{'number'} <= 12)) {
	#	$initvol = 0;
	#} 
	#else { 
	#	$initvol = 3; 
	#}
	foreach my $note (@{$measure->{'note'}}) {
		if ($note->{'staff'} == 2) {
			if (!$PRINTOUT) {
				print Dumper $note;
			}
			my $dur = $note->{'duration'} - 1;
			my $pitch = $notemap->{$note->{'pitch'}->{'step'}};
			if ($note->{'pitch'}->{'alter'}) {
				$pitch += $note->{'pitch'}->{'alter'};
			}
			my $octave = $note->{'pitch'}->{'octave'};
			my $attack = $initvol << 2 | 3;
			my $notecode = sprintf("0x%x%x%x%x", $attack, $dur, $octave, $pitch); 
			if (!$PRINTOUT) {
				printf ("measure %d  : notecode: %s\n", $measure->{'number'}, $notecode);
				printf("%x %x\n", $initvol << 2, 2);
			}
			push @score, $notecode;
		}
	}
#}
}

#print Dumper @score;
if ($PRINTOUT) {
printf("#define NUM_SONG %d\n\n", scalar @score);
printf("uint16_t song[] = {\n");
foreach my $thenote (@score) {
	printf("$thenote,\n");
}
printf("};\n\n");
}


