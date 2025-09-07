#!/usr/bin/perl
################################################################################
#   musicxml2mixtape.pl
#   07/14/2025 Ramon Ricca         Based on prototype readxml_measure.pl
################################################################################
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

print "What should the intial volume be? (1-15) ";
my $initial = <STDIN>;
chomp($initial);
if (($initial !~ /^\d+$/) || ($initial < 1) || ($initial > 15)) {
    die "Initial volume needs to be a decimal digit 1-15!";
}

print "What should the standard sustain level be? (1-15) ";
my $sustain = <STDIN>;
chomp($sustain);
if (($sustain !~ /^\d+$/) || ($sustain < 1) || ($sustain > 15)) {
    die "Sustain volume needs to be a decimal digit 1-15!";
}

print "What should the standard decay level be? (0-15) ";
my $decay = <STDIN>;
chomp($decay);
if (($decay !~ /^\d+$/) || ($decay < 0) || ($decay > 15)) {
    die "Decay needs to be a decimal digit 0-15!";
}

print "What should the standard duty value be? (0-15) ";
my $duty = <STDIN>;
chomp($duty);
if (($duty !~ /^\d+$/) || ($duty < 0) || ($duty > 15)) {
    die "Duty needs to be a decimal digit 0-15!";
}

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
	printf("#define DATAWIDTH %d\n", length($score[0]));
	printf("#define NUM_SONG %d\n", scalar @score);
	#printf("#define NUM_MEASURES %d\n\n", $maxmeasures);

	printf("const char song[NUM_SONG][DATAWIDTH] = {\n", scalar @score);
	foreach my $thenote (@score) {
		printf("\"$thenote\",\n");
	}
	printf("};\n\n");
}


# 02 01 02 03 04 0c 0a 01
