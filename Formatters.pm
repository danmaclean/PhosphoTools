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




=head1 NAME

Formatters - a module that includes code for writing in formats commonly used in proteomics

=head1 AUTHOR

Dan MacLean (dan.maclean@tsl.ac.uk)

=head1 SYNOPSIS

	use PhosphoTools::Formatters;
	
	my $mgf_out = Formatters::print_mgf(\%mgf);
	print $mgf; #prints out an MGF format file

=head1 DESCRIPTION

The formatters module contains code for writing out various TSL and proteomics formats. Extra formats can be added on request. The module does not create objects like some of the other modules, rather its methods are accessed in the manner of subroutines in external files.

=head1 METHODS

=over

=item make_format_string(phoscalc_score_string, best_guess_range)

Allows you to create a nicely formatted 'best-guess' PhosCalc score based on all the scores for a peptide. The parameter 'phocalc_score_string'
should be in a format that is internal to the standalone version of PhosCalc and some early text files. Thus this method is a bit esoteric and may
not find general utility. Remains because at present it is doing no harm.

=item print_mgf()

Returns a string version of an MGF record, the mgf hash you provide it with can be one of those created automatically with the PhosphoTools::Parsers 
get_mgf method. ALternatively you can populate one directly, create a hash with following keys:

	TITLE CHARGE TOL TOLU SEQ COMP TAG ETAG ETAG SCANS RTINSECONDS INSTRUMENT IT_MODS PEPMASS SPECTRA_PEAKS

Put the relevant information in the value for each key and the print_mgf method will print it out nice for you. You dont need to use all the keys for the
code to work. Use as many as you see fit.

	my %mgf;
	$mgf{'TITLE'} = "A_PEPTIDE_RESULT";
	$mgf{'CHARGE'} = '2+';
	.
	.
	.
	.

	my $mgf_out = Formatters::print_mgf(\%mgf);
	print $mgf_out; #prints out an MGF format file

=back

=head1 SEE ALSO
PhosphoTools::Parsers;
