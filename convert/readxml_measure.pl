#!/usr/bin/perl
use IO::Uncompress::Unzip qw(unzip $UnzipError) ;
use XML::Simple;
use Data::Dumper;
use strict;


my $fn = $ARGV[0];
die "Use xml filename as argument." if !$fn;

my ($z, $ref, $xml);

if ($fn =~ /\.mxl$/) {
	unzip $fn => \$z;
	$z =~ /full-path="(\w+).xml"/s;
	if ($1) {
		unzip $fn => \$xml, Name => "$1.xml";
		$ref = XMLin(\$xml);
	}
	else {
		die "Could not find xml file in zip.";
	}
}
elsif ( $fn =~ /\.xml$/) {
	$ref = XMLin($fn);
}
#print Dumper $ref;
#struct envelope {
#	 unsigned int		  duty : 4; 	// 7 = 50% duty cycle
#    unsigned int         initial : 4; 	// Initial Volume
#    unsigned int         sustain : 4; 	// Second Volume
#    unsigned int         decay : 4; 	// Final Volume
#};

my $initial = 12;
my $sustain = 10;
my $decay = 1;
my $duty = 4;
#my $envspec = $duty << 12 | $initial << 8 | $sustain << 4 | $decay;
my $envspec = sprintf("%02x%02x%02x%02x", $duty, $initial, $sustain, $decay);


my $PRINTOUT = 1;
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

#print Dumper $ref;
#exit(1);

my @score;
my $tb = 0;
my $maxmeasures = 0;
my $stage;
if (exists $ref->{'part'}->{'measure'}) {
	foreach my $measure (@{$ref->{'part'}->{'measure'}}) {
		my $totalbeats = ref $measure->{'backup'} eq 'HASH' ? $measure->{'backup'}->{'duration'} : $measure->{'backup'}->[0]->{'duration'};
		if (!$tb) {
			$tb = $totalbeats;
		}
		my $formmeasure;

		my $initvol = 1;

		$formmeasure->{'numnotes'} =  scalar @{$measure->{'note'}};
		$formmeasure->{'totalbeats'} = $totalbeats;
		my $voice = 0;
		my $staff;
		my $curvoice = 1;
		$staff = $totalbeats;
		foreach my $note (@{$measure->{'note'}}) {
			my ($pitch, $octave, $notecode);
			if (!$staff) {
				$staff = $totalbeats;
				$voice++;
			}
			#if (!$PRINTOUT) {
			#	print Dumper $note;
			#}
			my $dur = $note->{'duration'};
			$staff -= $dur;
			#$dur--;
			if (exists $note->{'rest'}) {
				$pitch = 12;
				$octave = 1;
			}
			elsif (exists $note->{'chord'}) {
				$pitch = $notemap->{$note->{'pitch'}->{'step'}};
				if ($note->{'pitch'}->{'alter'}) {
					$pitch += $note->{'pitch'}->{'alter'};
				}
				$octave = $note->{'pitch'}->{'octave'};
			}			
			else {
				$pitch = $notemap->{$note->{'pitch'}->{'step'}};
				if ($note->{'pitch'}->{'alter'}) {
					$pitch += $note->{'pitch'}->{'alter'};
				}
				$octave = $note->{'pitch'}->{'octave'};
			}
			#$octave--;
			$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
			if (length($notecode) != 9) {
				print "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n";
			}
			$maxmeasures = $measure->{'number'};
			if (!$PRINTOUT) {
				printf ("measure %d  : notecode: %s\n", $measure->{'number'}, $notecode);
				printf("%x %x\n", $initvol << 2, 2);
			}

			#push @{$formmeasure->{$voice}}, $notecode;
			push @score, $notecode;
		}
		#push @score, $formmeasure;
	}
}
else {
	foreach my $part (sort { $a <=> $b } keys %{$ref->{'part'}}) {
		my $voice = 0;
		my $mnum;
		foreach my $measure (@{$ref->{'part'}->{$part}->{'measure'}}) {
			my $totalbeats = ref $measure->{'backup'} eq 'HASH' ? $measure->{'backup'}->{'duration'} : $measure->{'backup'}->[0]->{'duration'};
			if (!$tb) {
				$tb = $totalbeats;
			}
			my $formmeasure;

			my $initvol = 1;
			$mnum = $measure->{'number'};
			$formmeasure->{'totalbeats'} = $totalbeats;
			#my $voice = 0;
			my $staff;
			#my $curvoice = 1;
			$staff = $totalbeats;
			my $dur;
			my ($pitch, $octave, $notecode);
			if (ref $measure->{'note'} eq 'HASH') {
				if (exists $measure->{'note'}->{'rest'}) {
					$pitch = 12;
					$octave = 1;
					$dur = $measure->{'note'}->{'duration'};
				}

				my $notecode = sprintf("%02x%x%x%x%x%x%x%x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
				if (length($notecode) != 9) {
					print "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n";
				}
				push @score, $notecode;
			}
			else {
				$formmeasure->{'numnotes'} =  scalar @{$measure->{'note'}};
				foreach my $note (@{$measure->{'note'}}) {
					if (!$staff) {
						$staff = $totalbeats;
						$voice++;
					}
					#if (!$PRINTOUT) {
					#	print Dumper $note;
					#}
					$dur = $note->{'duration'};
					$staff -= $dur;
					#$dur--;
					if (exists $note->{'rest'}) {
						$pitch = 12;
						$octave = 1;
					}
					elsif (exists $note->{'chord'}) {
						$pitch = $notemap->{$note->{'pitch'}->{'step'}};
						if ($note->{'pitch'}->{'alter'}) {
							$pitch += $note->{'pitch'}->{'alter'};
						}
						$octave = $note->{'pitch'}->{'octave'};
					}			
					else {
						$pitch = $notemap->{$note->{'pitch'}->{'step'}};
						if ($note->{'pitch'}->{'alter'}) {
							$pitch += $note->{'pitch'}->{'alter'};
						}
						$octave = $note->{'pitch'}->{'octave'};
					}
					#$octave--;
					$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
					if (length($notecode) != 9) {
						print "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n";
	                }

					$maxmeasures = $measure->{'number'};
					if (!$PRINTOUT) {
						printf ("measure %d  : notecode: %s\n", $measure->{'number'}, $notecode);
						printf("%x %x\n", $initvol << 2, 2);
					}

					#push @{$formmeasure->{$voice}}, $notecode;
					push @{$stage->{$mnum}}, $notecode;
				}
			}
			#push @score, $formmeasure;
		}
		$voice++;
	}

	foreach my $measnum (sort { $a <=> $b} keys %{$stage}) {
		push @score, @{$stage->{$measnum}};
	}
}
#print Dumper @score;
#exit(1);
if ($PRINTOUT) {
	#printf("#define DATAWIDTH %d\n", length($score[0]));
	#printf("#define NUM_SONG %d\n", scalar @score);
	#printf("#define NUM_MEASURES %d\n\n", $maxmeasures);

	#printf("const char song[NUM_SONG][DATAWIDTH] = {\n", scalar @score);
	foreach my $thenote (@score) {
		printf("ADD $thenote\n");
	}
	#printf("};\n\n");
}


# 02 01 02 03 04 0c 0a 01
