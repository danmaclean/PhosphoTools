package Formatters;
#################################
#
#module of methods for printing sequences in formats used in proteomics .. 
#################################
use strict;
use Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 0.1;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw();
%EXPORT_TAGS = (DEFAULT => [qw()],
				ALL =>[qw()]);

sub make_format_string{
	my %scores;
	my $lowest;
	my $passed;
	my $ptm_scores = shift;
	my $range = shift;
	$ptm_scores =~ s/\s+//g;
	my @sc = split(/\;/, $ptm_scores);
	foreach my $s (@sc){

		my @i = split(/\:/, $s);
		next unless $i[1];
		my $dec = expand($i[1]);
		#warn $dec, "\n"; sleep 1;
		$scores{$i[0]} = $dec;
		
	}

	foreach my $value (sort {$scores{$a} cmp $scores{$b} }
           keys %scores){
		if (!defined $lowest){
			$lowest = $value;
			$passed = $value;
			#warn "$lowest is highest\n$scores{$lowest}\n";
			my $min = $scores{$lowest} * $range;
			#warn "min is ", $min, "\n";

		}
		elsif(defined $lowest and ($scores{$value} <= $scores{$lowest} * $range)){

			$passed = $passed . ':' . $value;			

		}

	

	}

	my @passes = split(/\:/, $passed);

	if ($passes[1]){
		
		my %posns;
		foreach my $pass (@passes){
		#warn $pass, "\n"; sleep 2;
		$pass =~ s/[\#@\*\^]//g;
		while($pass =~ m/(\[)/){
			my $match = $`; #`
			my $pos = length($match);
			#warn $pos, " is pos\n";
			$posns{$pos} = 1;
			$pass =~ s/\[//;
			$pass =~ s/\]//;
			#warn "added $pos\n"; 
			}
		}

		#foreach my $key (keys %posns){

		#	warn $key, "=> is key\n";

		#}

		$passes[0] =~ s/[\[\]]//;;

		#warn $passes[0], "\n";

		
		my @res = split(/|/, $passes[0]);
		my $format_string = '';
		for (my $i = 0; $i < length($passes[0]); $i++){

		if (exists $posns{$i}){

			$format_string = $format_string . '[' . lc($res[$i]) . ']';
			
		}
		else {

			$format_string = $format_string . $res[$i];

		}


		}

		return $format_string;

	}
	else{
		my %posns; 
		$passes[0] =~ s/[\#@\*\^]//g;
		$passes[0] =~ m/(\[)/;
		my $match = $`; #`
		my $pos = length($match);
		$posns{$pos} = 1;
		$passes[0] =~ s/[\[\]]//g;
		my @res = split(/|/, $passes[0]);
		my $format_string = '';
		for (my $i = 0; $i < length $passes[0]; $i++){

		if (exists $posns{$i}){

			$format_string = $format_string . '[p' . $res[$i] . ']' ;

		}
		else {

			$format_string = $format_string . $res[$i];

		}


		}

		return $format_string;

	}

	
}
sub print_mgf{

	my $mgf = shift;

	my @printable_records = qw(TITLE CHARGE TOL TOLU SEQ COMP TAG ETAG ETAG SCANS RTINSECONDS INSTRUMENT IT_MODS PEPMASS);

	my $print_string = 'BEGIN IONS';

	foreach my $p (@printable_records){

		if (defined $mgf->{$p}){
	
			$print_string = $print_string . "\n" . $p . '=' . $mgf->{$p};

		}
	}
	$print_string = $print_string . "\n" . $mgf->{'spectra_peaks'} . "\n" . 'END IONS' . "\n\n";

	return $print_string;

}


####################################################################
sub expand {
        my $n = shift;
        return $n unless $n =~ /^(.*)e([-+]?)(.*)$/;
        my ($num, $sign, $exp) = ($1, $2, $3);
        my $sig = $sign eq '-' ? "." . ($exp - 1 + length $num) : '';
        return sprintf "%${sig}f", $n;
}



1;
