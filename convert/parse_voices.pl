#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
use strict;

my @narr = qw|
	c
	c+d-
	d
	d+e-
	e
	f
	f+g-
	g
	g+a-
	a
	a+b-
	b
|;

my $fn = $ARGV[0];
die "Use c code filename as argument." if !$fn;

open(my $fh, "<", $fn) or die "Could not open $fn";
my @score = <$fh>;
chomp(@score);
close($fh);

my $voice;
my $total;
my $voice;

my $maxmeasures;
my $numvoices;
foreach my $note (@score) {
	if ($note =~ /^#define TOTALBEATDIVS (\d+)/) {
		$total = $1;
		next;
	}
	elsif ($note =~ /^#define NUM_MEASURES (\d+)/) {
		$maxmeasures = $1;
		next;
	}
	elsif ($note =~ /^#define/) {
		next;
	}
	elsif ($note =~ /^char/) {
		next;
	}
	elsif ($note =~ /[\{\}]/) {
		next;
	}
	elsif ($note =~ /^$/) {
		next;
	}


	$note =~ s/[',]//g;
	my @seg = split("-", $note);

	my $hash = {
		#'measure' => $seg[0],
		#'remaining_dur' => $seg[1],
		'duration' => $seg[0],
		'voice' => $seg[1],
		'envspec' => $seg[2],
		'octave' => $seg[3],
		'pitch' => $seg[4],
	};
	#$maxmeasures = $seg[0];
	$numvoices->{$seg[1]} = 1;
	push @{$voice->{$seg[1]}}, $hash;
}

my $seq;
my $next;
my @voicelist = sort { $a <=> $b } keys %{$numvoices};
my $maxvoice = pop @voicelist;
my $curnote;
my $next;
my $last;
for (my $i=0; $i<=$maxvoice; $i++) {
	$curnote->{$i} = shift @{$voice->{$i}};
	$next->{$i} = 0;
	$last .= '1';
}

while($last != 0) {
	foreach my $n (sort { $a <=> $b } keys %{$next}) {
		if ($next->{$n}) {
			$curnote = next_note($n, $curnote);
			$next->{$n} = 0;
		}
	}
	play($curnote);
	$curnote = decrement($curnote);
	delay();
}


sub next_note {
	my ($v, $c) = @_;
	
	print "Next: $v\n";
	if (@{$voice->{$v}}) {
		$c->{$v} = shift @{$voice->{$v}};
	}
	else {
		substr($last, $v, 1, '0');
	}

	return $c;
}

sub play {
	my $c = shift;

	print "Playing:\n";
	foreach my $cv (sort { $a <=> $b } keys %{$c}) {
		printf("voice: %d  note: %s  duration %d\n", $cv, getnote($c->{$cv}), $c->{$cv}->{'duration'});
	}
}

sub decrement {
	my $c = shift;

	for (my $i=0; $i<=$maxvoice; $i++) {
		$c->{$i}->{'duration'}--;
		if (!$c->{$i}->{'duration'}) {
			$next->{$i} = 1 if (substr($last, $i, 1));
		}
	}

	return $c;
}

sub delay {
	for (my $t=0; $t < 2000; $t++) {
		;
	}
}

sub getnote {
	my $c = shift;

	my $str = $c->{'octave'} . $narr[$c->{'pitch'}];

	return $str;
}