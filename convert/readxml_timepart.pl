#!/usr/bin/perl
use XML::XSLT;
use XML::Simple;
use Data::Dumper;
use strict;

my $xslt = XML::XSLT->new ("/home/rricca/sounds/xsd/3.1/musicxml-3.1/schema/timepart.xsl", warnings => 1);

my $FORCEDRUM = 1;

my $fn = $ARGV[0];
die "Use xml filename as argument." if !$fn;

my $part = $ARGV[1];

$xslt->transform ($fn);

my ($z, $ref, $xml);

$ref = XMLin($xslt->toString, ForceArray => ['note', 'pitch', 'backup', 'measure']);
$xslt->dispose();
#print STDERR Dumper $ref;
my ($beat, $beat_type, $divisions, $totalbeats);
if (exists $ref->{'part'}->{'measure'}->[0]->{'attributes'}) {
    $beat 		= $ref->{'part'}->{'measure'}->[0]->{'attributes'}->{'time'}->{'beats'};
    $beat_type 	= $ref->{'part'}->{'measure'}->[0]->{'attributes'}->{'time'}->{'beat-type'};
    $divisions 	= $ref->{'part'}->{'measure'}->[0]->{'attributes'}->{'divisions'};
    $totalbeats = $divisions * $beat;
}
elsif(exists $ref->{'part'}->{$part}->{'measure'}->[0]->{'attributes'}) {
    $beat 		= $ref->{'part'}->{$part}->{'measure'}->[0]->{'attributes'}->{'time'}->{'beats'};
    $beat_type 	= $ref->{'part'}->{$part}->{'measure'}->[0]->{'attributes'}->{'time'}->{'beat-type'};
    $divisions 	= $ref->{'part'}->{$part}->{'measure'}->[0]->{'attributes'}->{'divisions'};
    $totalbeats = $divisions * $beat;
}

#print "TOTAL $beat $beat_type $divisions $totalbeats\n";
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
my $measnum;
my $maxvoices = 0;
#print Dumper $ref->{'part'};
if (exists $ref->{'part'}->{'measure'} && !$part) {
	foreach my $measure (@{$ref->{'part'}->{'measure'}}) {
		$measnum = $measure->{'number'};
		my $totalbeats = ref $measure->{'backup'} eq 'HASH' ? $measure->{'backup'}->{'duration'} : $measure->{'backup'}->[0]->{'duration'};
		if (!$tb) {
			$tb = $totalbeats;
		}
		#my $formmeasure;

		my $initvol = 1;

		#$formmeasure->{'numnotes'} =  scalar @{$measure->{'note'}};
		#$formmeasure->{'totalbeats'} = $totalbeats;
		my $voice = 0;
		my $staff;
		my $curvoice = 1;
		$staff = $totalbeats;
		foreach my $note (@{$measure->{'note'}}) {
			my ($pitch, $octave, $notecode);
			if (!$staff) {
				$staff = $totalbeats;
				$voice++;
                if ($voice > $maxvoices) {
                    $maxvoices = $voice;
                }
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
				$pitch = $notemap->{$note->{'pitch'}->[0]->{'step'}};
				if ($note->{'pitch'}->[0]->{'alter'}) {
					$pitch += $note->{'pitch'}->[0]->{'alter'};
				}
				$octave = $note->{'pitch'}->[0]->{'octave'};
			}			
			else {
				$pitch = $notemap->{$note->{'pitch'}->[0]->{'step'}};
				if ($note->{'pitch'}->[0]->{'alter'}) {
					$pitch += $note->{'pitch'}->[0]->{'alter'};
				}
				$octave = $note->{'pitch'}->[0]->{'octave'};
			}
			#$octave--;
			$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $FORCEDRUM ? 3 : $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
			if (length($notecode) != 9) {
                if (($pitch < 0) && (exists $note->{'pitch'}->[0]->{'alter'}) && ($notemap->{$note->{'pitch'}->[0]->{'step'}} == 0)) {
                        $pitch = 12 + $note->{'pitch'}->[0]->{'alter'};
                        #$octave = $note->{'pitch'}->[0]->{'octave'} - 1;
                        $notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $FORCEDRUM ? 3 : $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
                }
                elsif ($pitch > 15) {
                    $pitch -= 12;
                    $octave++;
                    $notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $FORCEDRUM ? 3 : $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
                }
                else {
                    warn "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n" . Dumper $note;
                }
            }	
			$maxmeasures = $measure->{'number'};
			if (!$PRINTOUT) {
				printf ("measure %d  : notecode: %s\n", $measure->{'number'}, $notecode);
				printf("%x %x\n", $initvol << 2, 2);
			}

			#push @{$formmeasure->{$voice}}, $notecode;
			push @{$stage->{$measnum}}, $notecode;
		}
		#push @score, $formmeasure;
	}
}
elsif (exists $ref->{'part'}->{$part}) {
	foreach my $measure (@{$ref->{'part'}->{$part}->{'measure'}}) {
		$measnum = $measure->{'number'};
		my $totalbeats = ref $measure->{'backup'} eq 'HASH' ? $measure->{'backup'}->{'duration'} : $measure->{'backup'}->[0]->{'duration'};
		if (!$tb) {
			$tb = $totalbeats;
		}
		#my $formmeasure;

		my $initvol = 1;

		#$formmeasure->{'numnotes'} =  scalar @{$measure->{'note'}};
		#$formmeasure->{'totalbeats'} = $totalbeats;
		my $voice = 0;
		my $staff;
		my $curvoice = 1;
		$staff = $totalbeats;
		foreach my $note (@{$measure->{'note'}}) {
			my ($pitch, $octave, $notecode);
			if (!$staff) {
				$staff = $totalbeats;
				$voice++;
                if ($voice > $maxvoices) {
                    $maxvoices = $voice;
                }
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
				$pitch = $notemap->{$note->{'pitch'}->[0]->{'step'}};
				if ($note->{'pitch'}->[0]->{'alter'}) {
					$pitch += $note->{'pitch'}->[0]->{'alter'};
				}
				$octave = $note->{'pitch'}->[0]->{'octave'};
			}			
			else {
				$pitch = $notemap->{$note->{'pitch'}->[0]->{'step'}};
				if ($note->{'pitch'}->[0]->{'alter'}) {
					$pitch += $note->{'pitch'}->[0]->{'alter'};
				}
				$octave = $note->{'pitch'}->[0]->{'octave'};
			}
			#$octave--;
			$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $FORCEDRUM ? 3 : $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
			if (length($notecode) != 9) {
                if (($pitch < 0) && (exists $note->{'pitch'}->[0]->{'alter'}) && ($notemap->{$note->{'pitch'}->[0]->{'step'}} == 0)) {
                        $pitch = 12 + $note->{'pitch'}->[0]->{'alter'};
                        #$octave = $note->{'pitch'}->[0]->{'octave'} - 1;
                        $notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $FORCEDRUM ? 3 : $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
                }
                elsif ($pitch > 15) {
                    $pitch -= 12;
                    $octave++;
                    $notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $FORCEDRUM ? 3 : $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
                }
                else {
                    warn "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n" . Dumper $note;
                }
            }	
			$maxmeasures = $measure->{'number'};
			if (!$PRINTOUT) {
				printf ("measure %d  : notecode: %s\n", $measure->{'number'}, $notecode);
				printf("%x %x\n", $initvol << 2, 2);
			}

			#push @{$formmeasure->{$voice}}, $notecode;
			push @{$stage->{$measnum}}, $notecode;
		}
		#push @score, $formmeasure;
	}
}
# else {
# 	foreach my $part (sort { $a <=> $b } keys %{$ref->{'part'}}) {
# 		my $voice = 0;
# 		my $mnum;
# 		foreach my $measure (@{$ref->{'part'}->{$part}->{'measure'}}) {
# 		    $measnum = $measure->{'number'};
# 			my $totalbeats = ref $measure->{'backup'} eq 'HASH' ? $measure->{'backup'}->{'duration'} : $measure->{'backup'}->[0]->{'duration'};
# 			if (!$tb) {
# 				$tb = $totalbeats;
# 			}
# 			#my $formmeasure;

# 			my $initvol = 1;
# 			$mnum = $measure->{'number'};
# 			#$formmeasure->{'totalbeats'} = $totalbeats;
# 			#my $voice = 0;
# 			my $staff;
# 			#my $curvoice = 1;
# 			$staff = $totalbeats;
# 			my $dur;
# 			my ($pitch, $octave, $notecode);
# 			if (ref $measure->{'note'} eq 'HASH') {
# 				if (exists $measure->{'note'}->{'rest'}) {
# 					$pitch = 12;
# 					$octave = 1;
# 					$dur = $measure->{'note'}->{'duration'};
# 				}

# 				my $notecode = sprintf("%02x%x%x%x%x%x%x%x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
# 				if (length($notecode) != 9) {
# 					print "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n";
# 				}
# 				push @{$stage->{$measnum}}, $notecode;
# 			}
# 			else {
# 				#$formmeasure->{'numnotes'} =  scalar @{$measure->{'note'}};
# 				foreach my $note (@{$measure->{'note'}}) {
# 					if (!$staff) {
# 						$staff = $totalbeats;
# 						$voice++;
#                         if ($voice > $maxvoices) {
#                             $maxvoices = $voice;
#                         }
# 					}
# 					#if (!$PRINTOUT) {
# 					#	print Dumper $note;
# 					#}
# 					$dur = $note->{'duration'};
# 					$staff -= $dur;
# 					#$dur--;
# 					if (exists $note->{'rest'}) {
# 						$pitch = 12;
# 						$octave = 1;
# 					}
# 					elsif (exists $note->{'chord'}) {
# 						$pitch = $notemap->{$note->{'pitch'}->{'step'}};
# 						if ($note->{'pitch'}->[0]->{'alter'}) {
# 							$pitch += $note->{'pitch'}->[0]->{'alter'};
# 						}
# 						$octave = $note->{'pitch'}->[0]->{'octave'};
# 					}			
# 					else {
#                         print Dumper $note;
# 						$pitch = $notemap->{$note->{'pitch'}->[0]->{'step'}};
# 						if ($note->{'pitch'}->[0]->{'alter'}) {
# 							$pitch += $note->{'pitch'}->[0]->{'alter'};
# 						}
# 						$octave = $note->{'pitch'}->[0]->{'octave'};
# 					}
# 					#$octave--;
# 					$notecode = sprintf("%02x%1x%1x%1x%1x%1x%1x%1x", $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay); 
# 					if (length($notecode) != 9) {
# 						print "ERROR $dur, $voice, $octave, $pitch, $duty, $initial, $sustain, $decay\n";
# 	                }

# 					$maxmeasures = $measure->{'number'};
# 					if (!$PRINTOUT) {
# 						printf ("measure %d  : notecode: %s\n", $measure->{'number'}, $notecode);
# 						printf("%x %x\n", $initvol << 2, 2);
# 					}

# 					#push @{$formmeasure->{$voice}}, $notecode;
# 				    push @{$stage->{$measnum}}, $notecode;
# 				}
# 			}
# 			#push @score, $formmeasure;
# 		}
# 		$voice++;
# 	}

# 	foreach my $measnum (sort { $a <=> $b} keys %{$stage}) {
# 		push @score, @{$stage->{$measnum}};
# 	}
# }
#print Dumper @score;
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
	printf("#define DATAWIDTH %d\n", 9);
	printf("#define NUM_SONG %d\n", $numscore);
	#printf("#define NUM_MEASURES %d\n\n", $maxmeasures);

	printf("const char song[NUM_SONG][DATAWIDTH] = {\n", scalar @score);
	foreach my $measure (sort {$a <=> $b} keys %{$stage}) {
		foreach my $note (@{$stage->{$measure}}) {
			printf("\"$note\",\n");
		}
	}

	printf("};\n\n");
}
