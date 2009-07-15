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
#my $specific_residue = shift; ### if this is set will return phos posns only for one type of residue, options are S, T, Y and ALL

#if (!$specific_residue or $specific_residue =~ m/all/i){
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
#			$best_guess =~ s/\[//;
			$best_guess =~ s/\]//;
			#warn "added $pos\n";
			$pos += $pep_start;

			$phos_site_posns{'specific'}{$pos} = 1; 
			
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
#			$best_guess =~ s/\[p//;
			$pep =~ s/\[//;
			$pep =~ s/\]//;
			#warn "added $pos\n";
			$pos += $pep_start;

			$phos_site_posns{'ambiguous'}{$pos} = 1; 
			
		    }

return %phos_site_posns;
 }
sub get_phossite_positions{

my $protein = shift;
my $best_guess = shift;
my $pep_start = shift;
my $pep_end = shift;
#my $specific_residue = shift; ### if this is set will return phos posns only for one type of residue, options are S, T, Y and ALL

#if (!$specific_residue or $specific_residue =~ m/all/i){
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

#}
#elsif ($specific_residue =~ m/s/i or $specific_residue =~ m/t/i or $specific_residue =~ m/y/i){

#$specific_residue = uc($specific_residue);
#$best_guess =~ s/\(/[/g;
#$best_guess =~ s/\)/]/g;
#$best_guess =~ s/\[p/[/g;
#$best_guess =~ s/\[ox/[/g;
#$best_guess =~ s/\[\*/\[/g;
#my %phos_site_posns;

#		while($best_guess =~ m/(\[$specific_residue)/gi){
#			my $match = $`; #`
#			my $pos = length($match);
#			$best_guess =~ s/\[//;
#			$best_guess =~ s/\]//;
			#warn "added $pos\n";
#			$pos += $pep_start;

#			$phos_site_posns{$pos} = 1; 
			
#		}

#return %phos_site_posns;
#}

#return -1;

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





1;
