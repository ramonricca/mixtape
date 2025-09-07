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

my $adsr = $ARGV[1];
my $thepart = $ARGV[2];

my ($z, $ref, $xml);
if ( $fn =~ /\.xml$/) {
	$ref = XMLin($fn);
}
else {
    die "score should have .xml extension.";
}

if (!$adsr) {
	die "Need to add adsr as second argument. Duty-Initial-Sustain-Decay. e.g. 8FC2.";
}


my ($beat, $beat_type, $divisions, $totalbeats);
if (exists $ref->{'part'}->{'measure'}->[0]->{'attributes'}) {
   $beat 		= $ref->{'part'}->{'measure'}->[0]->{'attributes'}->{'time'}->{'beats'};
    $beat_type 	= $ref->{'part'}->{'measure'}->[0]->{'attributes'}->{'time'}->{'beat-type'};
    $divisions 	= $ref->{'part'}->{'measure'}->[0]->{'attributes'}->{'divisions'};
    $totalbeats = $divisions * $beat;
}
#print "beat $beat beat_type $beat_type divisions $divisions totalbeats $totalbeats\n";

#warn "beat $beat beat_type $beat_type divisions $divisions totalbeats $totalbeats";


# print "What should the intial volume be? (1-15) ";
# my $initial = <STDIN>;
# chomp($initial);
# if (($initial !~ /^\d+$/) || ($initial < 1) || ($initial > 15)) {
#     die "Initial volume needs to be a decimal digit 1-15!";
# }

# print "What should the standard sustain level be? (1-15) ";
# my $sustain = <STDIN>;
# chomp($sustain);
# if (($sustain !~ /^\d+$/) || ($sustain < 1) || ($sustain > 15)) {
#     die "Sustain volume needs to be a decimal digit 1-15!";
# }

# print "What should the standard decay level be? (0-15) ";
# my $decay = <STDIN>;
# chomp($decay);
# if (($decay !~ /^\d+$/) || ($decay < 0) || ($decay > 15)) {
#     die "Decay needs to be a decimal digit 0-15!";
# }

# print "What should the standard duty value be? (0-15) ";
# my $duty = <STDIN>;
# chomp($duty);
# if (($duty !~ /^\d+$/) || ($duty < 0) || ($duty > 15)) {
#     die "Duty needs to be a decimal digit 0-15!";
# }

$adsr =~ /^(\w)(\w)(\w)(\w)$/;
my $duty = hex($1);
my $initial = hex($2);
my $sustain = hex($3);
my $decay = hex($4);

#warn "ADSR $adsr duty $duty initial $initial sustain $sustain decay $decay";

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
my $maxvoices = 0;
my $measnum;
my $voice = 0;
my $staff;
$staff = $totalbeats;

if (($thepart) && (exists $ref->{'part'}->{$thepart}->{'measure'})) {
	foreach my $measure (@{$ref->{'part'}->{$thepart}->{'measure'}}) {
		$measnum = $measure->{'number'};
		$staff = $totalbeats;
		if (ref $measure->{'note'} eq 'ARRAY') {
			foreach my $note (@{$measure->{'note'}}) {
				my ($pitch, $octave, $notecode);
				if ($staff == 0) {
					$staff = $totalbeats;
					$voice++;
					if ($voice > $maxvoices) {
						$maxvoices = $voice;
					}
				}
				my $dur = $note->{'duration'};
				$staff -= $dur;

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

				$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
				if (length($notecode) != 9) {
					if (($pitch < 0) && (exists $note->{'pitch'}->{'alter'}) && ($notemap->{$note->{'pitch'}->{'step'}} == 0)) {
							$pitch = 12 + $note->{'pitch'}->{'alter'};
							$octave = $note->{'pitch'}->{'octave'} - 1;
							$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
					}
					elsif ($pitch > 15) {
						$pitch -= 12;
						$octave++;
						$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
					}
					else {
						warn "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n" . Dumper $note;
					}
				}				
				push @{$stage->{$measnum}}, $notecode;
			}
		}
		elsif (ref $measure->{'note'} eq 'HASH') {
			my $note = $measure->{'note'};
			my ($pitch, $octave, $notecode);
			if ($staff == 0) {
				$staff = $totalbeats;
				$voice++;
				if ($voice > $maxvoices) {
					$maxvoices = $voice;
				}
			}
			my $dur = $note->{'duration'};
			$staff -= $dur;

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

			$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
			if (length($notecode) != 9) {
				if (($pitch < 0) && (exists $note->{'pitch'}->{'alter'}) && ($notemap->{$note->{'pitch'}->{'step'}} == 0)) {
						$pitch = 12 + $note->{'pitch'}->{'alter'};
						$octave = $note->{'pitch'}->{'octave'} - 1;
						$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
				}
				elsif ($pitch > 15) {
					$pitch -= 12;
					$octave++;
					$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
				}
				else {
					warn "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n" . Dumper $note;
				}
			}			
			push @{$stage->{$measnum}}, $notecode;
		}
		$maxmeasures = $measure->{'number'};
	}
}
elsif (exists $ref->{'part'}->{'measure'}) {
	foreach my $measure (@{$ref->{'part'}->{'measure'}}) {
		$measnum = $measure->{'number'};
		$staff = $totalbeats;
		if (ref $measure->{'note'} eq 'ARRAY') {
			foreach my $note (@{$measure->{'note'}}) {
				my ($pitch, $octave, $notecode);
				if ($staff == 0) {
					$staff = $totalbeats;
					$voice++;
					if ($voice > $maxvoices) {
						$maxvoices = $voice;
					}
				}
				my $dur = $note->{'duration'};
				$staff -= $dur;

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

				$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
	
				if (length($notecode) != 9) {
					if (($pitch < 0) && (exists $note->{'pitch'}->{'alter'}) && ($notemap->{$note->{'pitch'}->{'step'}} == 0)) {
							$pitch = 12 + $note->{'pitch'}->{'alter'};
							$octave = $note->{'pitch'}->{'octave'} - 1;
							$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
					}
					elsif ($pitch > 15) {
						$pitch -= 12;
						$octave++;
						$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
					}
					else {
						warn "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n" . Dumper $note;
					}
				}				
				push @{$stage->{$measnum}}, $notecode;
			}
		}
		elsif (ref $measure->{'note'} eq 'HASH') {
			my ($pitch, $octave, $notecode);
			my $note = $measure->{'note'};

			if ($staff == 0) {
				$staff = $totalbeats;
				$voice++;
				if ($voice > $maxvoices) {
					$maxvoices = $voice;
				}
			}
			my $dur = $note->{'duration'};
			$staff -= $dur;

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

			$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
			if (length($notecode) != 9) {
				if (($pitch < 0) && (exists $note->{'pitch'}->{'alter'}) && ($notemap->{$note->{'pitch'}->{'step'}} == 0)) {
						$pitch = 12 + $note->{'pitch'}->{'alter'};
						$octave = $note->{'pitch'}->{'octave'} - 1;
						$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
				}
				elsif ($pitch > 15) {
					$pitch -= 12;
					$octave++;
					$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
				}
				else {
					warn "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n" . Dumper $note;
				}
			}			
			push @{$stage->{$measnum}}, $notecode;
		}
		$maxmeasures = $measure->{'number'};
	}
}

#print Dumper $stage;
#exit(1);

## equalize voices
foreach my $measure (sort {$a <=> $b} keys %{$stage}) {
	my $hashvoice;
	foreach my $note (@{$stage->{$measure}}) {
		$note =~ /^\d\d(\d)/;
		$hashvoice->{$1}++;
	}

	for (my $i=0; $i <= $maxvoices; $i++) {
		if (!exists $hashvoice->{$i}) {
			my $restnote = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $totalbeats, $i, 1, 12, 8, 0, 0, 0); 
			push @{$stage->{$measure}}, $restnote;
		}
	}
} 

my $numscore = 0;
foreach my $measure (sort {$a <=> $b} keys %{$stage}) {
	foreach my $note (@{$stage->{$measure}}) {
		$numscore++;
	}
}


#print Dumper @score;
#exit(1);
if ($PRINTOUT) {
	#printf("#define DATAWIDTH %d\n", 9);
	#printf("#define NUM_SONG %d\n", $numscore);
	#printf("#define NUM_MEASURES %d\n\n", $maxmeasures);

	#printf("const char song[NUM_SONG][DATAWIDTH] = {\n", scalar @score);
	foreach my $measure (sort {$a <=> $b} keys %{$stage}) {
		foreach my $note (@{$stage->{$measure}}) {
			#printf("\"$note\",\n");
			printf("ADD $note\n");
		}
	}

	#printf("};\n\n");
}


# 02 01 02 03 04 0c 0a 01

sub get_measure {
	my $measure = shift;
		#warn Dumper $measure->{'attributes'};

		if (ref $measure->{'note'} eq 'ARRAY') {
			foreach my $note (@{$measure->{'note'}}) {
				my $notecode = get_note($note);
				push @{$stage->{$measnum}}, $notecode;
			}
		}
		elsif (ref $measure->{'note'} eq 'HASH') {
			my $notecode = get_note($measure->{'note'});
			push @{$stage->{$measnum}}, $notecode;
		}

	return $stage;
}

sub get_note {
	my $note = shift;

	my ($pitch, $octave, $notecode);
	if ($staff == 0) {
		$staff = $totalbeats;
		$voice++;
		if ($voice > $maxvoices) {
			$maxvoices = $voice;
		}
	}
	my $dur = $note->{'duration'};
	$staff -= $dur;

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

	$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
	if (length($notecode) != 9) {
		if (($pitch < 0) && (exists $note->{'pitch'}->{'alter'}) && ($notemap->{$note->{'pitch'}->{'step'}} == 0)) {
				$pitch = 12 + $note->{'pitch'}->{'alter'};
				$octave = $note->{'pitch'}->{'octave'} - 1;
				$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
		}
		elsif ($pitch > 15) {
			$pitch -= 12;
			$octave++;
			$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
		}
		else {
			warn "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n" . Dumper $note;
		}
	}

	return $notecode;
}