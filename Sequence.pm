package Sequence;

#################################
#
#module of methods for operating on sequences and sequence formats used in proteomics 
#
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

sub clean_up_sequence{
#removes phospho formatting from a sequence
my $seq = shift;
$seq =~ s/\(/[/g;
$seq =~ s/\)/]/g;
$seq =~ s/\[p/[/g;
$seq =~ s/\[ox/[/g;
$seq =~ s/\[\*/\[/g;
$seq =~ s/\[//g;
$seq =~ s/\]//g;
$seq = uc($seq);
return $seq;


}


sub find_peptides_posn_on_protein{
#provide  a clean peptide sequence and clean protein... 
###warning - only finds the first match on the protein... 
my $peptide = shift;
my $protein = shift;

my $start = -100000;
my $end = -1000000;


$peptide = uc($peptide);
$protein = uc($protein);


	$protein =~ m/($peptide)/;
	my $match = $`; #`
	if (length($match) >=0){
		$start = length($match) + 1;
		$end = $start + length($peptide);
	}
 my @pos = ($start, $end); 
 return @pos;
}




sub get_residue_positions{

my $residue = shift;
my $protein = shift;
my %residue_posns;
		while($protein =~ m/($residue)/ig){
			my $match = $`; #`
			my $pos = length($match);
			$residue_posns{$pos} = 0; 
		}
return %residue_posns;

}
sub get_phossite_positions_specific_and_ambiguous{

my $protein = shift;
my $best_guess = shift;
my $pep = $best_guess;
my $pep_start = shift;
my $pep_end = shift;


$best_guess =~ s/\(/[/g;
$best_guess =~ s/\)/]/g;
$best_guess =~ s/\[s\]/s/gi;
$best_guess =~ s/\[t\]/t/gi;
$best_guess =~ s/\[y\]/y/gi;
$best_guess =~ s/\[ox/[/g;
$best_guess =~ s/\[\*/\[/g;
my %phos_site_posns;

		while($best_guess =~ m/(\[p)/g){
			my $match = $`; #`
			my $pos = length($match);
			$best_guess =~ s/\[p//;
			$best_guess =~ s/\]//;

			$pos += $pep_start;

			$phos_site_posns{$pos} = 1; 
			
		}
$pep =~ s/\(/[/g;
$pep  =~ s/\)/]/g;
$pep =~ s/\[pS\]/S/gi;
$pep =~ s/\[pT\]/T/gi;
		       $pep =~ s/\[pY\]/Y/gi;
		       warn $pep, "\n";
		while($pep =~ m/(\[)/g){
		        my $match = $`; #`
			my $pos = length($match);

			$pep =~ s/\[//;
			$pep =~ s/\]//;
			$pos += $pep_start;

			$phos_site_posns{$pos} = 1; 
			
		    }

return %phos_site_posns;
 }

sub get_phossite_positions{

my $protein = shift;
my $best_guess = shift;
my $pep_start = shift;
my $pep_end = shift;
my $type = shift;

die unless $type;

$best_guess =~ s/\(/[/g;
		     $best_guess =~ s/\)/]/g;

if ($type =~ m/d/i){
## if we are looking at definitive sites only

    $best_guess =~ s/\[(\w)\]/$1/g;


}
if ($type =~ m/a/i){
   ## if we are looking at ambiguous sites only
    $best_guess =~ s/\[p(\w)\]/$1/g;


}

$best_guess =~ s/\(/[/g;
$best_guess =~ s/\)/]/g;
$best_guess =~ s/\[p/[/g;
$best_guess =~ s/\[ox/[/g;
$best_guess =~ s/\[\*/\[/g;
my %phos_site_posns;

		while($best_guess =~ m/(\[)/g){
			my $match = $`; #`
			my $pos = length($match);
#			$best_guess =~ s/\[p//;
			$best_guess =~ s/\[//;
			$best_guess =~ s/\]//;
			#warn "added $pos\n";
			$pos += $pep_start;

			$phos_site_posns{$pos} = 1; 
			
		}
		

return %phos_site_posns;

}

sub make_alignment{
##returns a hash of peptides drawn  from the parent sequence of a peptide and aligned around a phossite ## if you give a set of phoscalc style probability scores it will generate the peptide alignments for all possible phossites over the 1e-06 arbitrary cutoff..... ### if you provide a best guess or phosphat formatted definitive format sequence ie PEP[pT]IDE then it will use just the definitive phos positions .. NB the [p   character is diagnostic of the best guess or phosphat format, if your sequence lacks this the code will think itis phoscalc or non-definitive

   
	my %alignments;
	my $seq = shift;
	my $ptm_line = shift; ## either phoscalc alternative or mod_pep from phosphat

	### be safe and strip out the weird shit from the mod pep, oxM and *@^# etc
	$ptm_line =~ s/\(/\[/g;
	$ptm_line =~ s/\)/\]/g;
	$ptm_line =~ s/\[oxM\]/M/ig;
	$ptm_line =~ s/[\#\^\@\*]//g;

	if ($ptm_line =~ m/\[p/ ){  # we have at least one definitive site 
		my $clean_seq = clean_up_sequence($ptm_line); ### make a clean sequence

		while ($ptm_line =~ m/\[p/g){
			my $match = $`; #`
			$match =~ s/\[p//; #`
			$match = clean_up_sequence($match); #`
			my $pos = length($match) + 1;
		#	warn "match is $match\t $clean_seq\n";
			if ($seq =~ m/$clean_seq/i){
		#		warn "found a place to align\n";
				my $start_of_match = length($`); #`
				my $s = ($start_of_match + $pos) - 7;
				my $alignment = substr($seq, $s, 13);
		#		warn $alignment, "\n";
				$alignments{$alignment} = 1;
			}
			$ptm_line =~ s/\[p//;
			$ptm_line =~ s/\]//;
		}
	}


	else { ## we are using phoscalc scores
		my @scores = split(/;/,$ptm_line);
		#		warn $seq, "\n";
		foreach my $score (@scores){
			$score =~ s/\s//g;
			my @info = split(/:/,$score);
				if (defined $info[0] and defined $info[1] and $info[1] <= 1e-06){
					$info[0] =~ m/\[/;
					my $match = $`; #`
					$match =~ s/[\#@\*]//g; #`
	#				warn $match, "\n";
					my $pos = length($match) + 1; #` 
	#				warn $info[0], "\t", $pos, "\n";
					my $frag = $info[0];
					$frag =~ s/[\[\]\#@\*]//g;
	#				warn $frag, "\t", $pos, "\n";
						if ($seq =~ m/$frag/){
						my $start_of_match = length($`); #`
						my $s = ($start_of_match + $pos) - 7;
						my $alignment = substr($seq, $s, 13);
		#				warn $alignment, "\n";
						$alignments{$alignment} = 1;
					}
				

				}	 
		}

	}
	return %alignments;




}
sub get_motif_alignment_from_position{
	my $seq = shift;
	my $pos = shift;
	my $s = $pos - 7;
	substr($seq, $s, 13);
}




1;
=head1 NAME

Sequences - a module that includes code for dealing with sequences of different formats commonly used in proteomics

=head1 AUTHOR

Dan MacLean (dan.maclean@tsl.ac.uk)

=head1 SYNOPSIS

	use PhosphoTools::Sequences;

	my $pep_mod = 'APEPTIDE[pS]EQUENCE';
	my $cleaned_pep = Sequences::clean_up_sequence($pep_mod);
	print $pep_mod; #prints APEPTIDESEQUENCE

=head1 DESCRIPTION

The Sequence module contains code for completing various tasks with peptide sequences.

=head1 METHODS

=over

=item clean_up_sequence(annotated_peptide_sequence)

Removes the phosphopeptide annotation from an annotated sequence

	my $pep_mod = 'APEPTIDE[pS]EQUENCE';
	my $cleaned_pep = Sequences::clean_up_sequence($pep_mod);
	print $pep_mod; #prints APEPTIDESEQUENCE

=item find_peptides_posn_on_protein(peptide, protein)

When provided with a (cleaned) peptide and a protein sequence, returns the start and end position on the protein of the first exact match as an array.

	my $pep = 'ROT';
	my $protein = 'APROTEINSEQUENCE';
	my @posns = Sequence::find_peptides_posn_on_protein($pep,$protein);
	print $posns[0], " ", $posns[1]; #prints 3 5 

=item get_residue_positions(residue, protein)

When provided with a single letter amino acid and a protein, will return a hash with keys that are the numeric positions of the residue in that protein

	my $res = 'E';
	my $protein = 'APROTEINSEQUENCE
	my %residue_positions = Sequence::get_residue_positions($res, $protein);
	print keys %residue_positions; #prints 6, 10, 13 and 16 in no particular order

=item get_phossite_positions(protein, annotated_peptide, start_on_prot, end_on_prot, type )

When provided with an a protein, annotated peptide sequence, the position on the protein where the peptide starts and ends and a type of phosite this
will return a hash of the phosite positions in the protein. 
The type argument is the type of phossite to look at, either 'ambiguous' (use 'a') or definite (use 'd')

	my $protein = 'APROTEINSEQUENCE';
	my $anno_pep = '[pT]EIN[pS]EQ;
	my $start = 5;
	my $end = 12;
	my %phossite_positions = Sequence::get_phossite_postions($protein, $anno_pep, $start, $end, 'd');
	print keys %phossite_positions; # prints 5 and 9

=item get_phossite_positions_specific_and_ambiguous()

As for get_phossite_positions() but lacks the type argument, returns positions for all annotated phossites. 

=item make_alignment(protein, annotated_peptide)

Returns a hash of 13 aa long peptides drawn from the parent sequence of a peptide and aligned around with the phossite at the centre.
if you give a set of phoscalc style probability scores it will generate the peptide alignments for all possible phossites over the 1e-06 arbitrary cutoff. 
If you provide a best guess or phosphat formatted definitive format sequence ie PEP[pT]IDE then it will use just the definitive phos positions
NB the [p character is diagnostic of the best guess or phosphat format, if your sequence lacks this the code will think it is phoscalc.

	my $seq = 'AVERYLONGPROTEINSEQ;
	my $ptm_line = O[pT]EIN; ## or phoscalc alternative
	my %alignments = Sequence::make_alignments($seq, $ptm_line);
	print keys %alignments; #prints ONGPROTEINSEQ

=item get_motif_alignment_from_position(protein, position)

Returns a single sub-sequence of 13 aas centered around a provided position, when provided with the protein	and position

	my $seq = 'AVERYLONGPROTEINSEQ';
	my $al = Sequence::make_alignments($seq, $pos);
	print $al; ##prints ONGPROTEINSEQ

=back

=head1 SEE ALSO
PhosphoTools::Formatters; PhosphoTools::Parsers; Bio::SeqIO;