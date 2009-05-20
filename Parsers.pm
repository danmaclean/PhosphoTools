package Parsers;


#################################
#
#module of methods for assisting with parsing files commonly used in proteomics db
#
#################################
use strict;
use Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 0.1;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(strip_whitespace_from_header);
%EXPORT_TAGS = (DEFAULT => [qw()],
				ALL =>[qw(strip_whitespace_from_header)]);
				

sub strip_whitespace_from_header{
	my $line = shift;
	my $sep = ',';
	$sep = shift if $_[0];
	my @tmp = split(/$sep/,$line);
	my @result;
	foreach my $c (@tmp){
		$c =~ s/\s+/_/g;
		push @result, $c;
	}
	
	return join($sep, @result);

	
	
}

sub parse_phossites{
	my %ptm_scores;
	my $ptmline = shift;
	$ptmline =~ s/\s//g;
	my @ps = split(/\;/, $ptmline);
	foreach my $var (@ps){
		my @t = split(/:/,$var);
		if (defined $t[0] and defined $t[1]){
			$ptm_scores{$t[0]} = $t[1];
			
		}
		return %ptm_scores;
	}
	
	
}

sub get_go_terms{
	my %goterms;
	my $gofile = shift;
	open FILE, "<$gofile" || die "cant open $gofile\n";
	while (my $line = <FILE>){
		chomp $line;
		my @info = split(/\t/, $line);
		my $goterm = $info[3];
		my $accession = $info[0];
		my $goid = $info[4];
		my $aspect = $info[6];
		my $termcomp = $goterm . ';' . $goid . ';'  . $aspect; 
		$goterms{$accession}{$termcomp} = 1;			

		
	}
	close FILE;
	return %goterms;
	
}

sub get_pfamhits{
	
	my $pfams = shift;
	open PFAMS, "<$pfams" || die "can't open PFAMS $pfams\n";
	my %pfams; 
	while (my $line = <PFAMS>){
		chomp $line;
		my @cell = split(/\s+/, $line);
			my $accession = $cell[0];
			my $start = $cell[1];
			my $stop = $cell[2];
			my $domainid = $cell[3];
			my $name = $cell[8];
			my $p = $cell[7];
			my $hitcomp = $name .  ';' . $start . ';' . $stop . ';'  .$p;
			$pfams{$accession}{$hitcomp}= 1 ;
		}
	close PFAMS;
	
	return %pfams; 
		
}


sub get_proteins{
my $sequence_file = shift;
my %proteins;

use Bio::SeqIO;
	my $stream = Bio::SeqIO->new(-format=>'fasta', -file=>$sequence_file);
	while(my $seq_obj = $stream->next_seq() ){
		my $id = $seq_obj->id;
		my $sequence = $seq_obj->seq;
		my $description = $seq_obj->description;
		my $description =~ s/\'//g;
		$proteins{$id}{'sequence'} = $sequence;
		$proteins{$id}{'description'} = $description;
		
	}


return %proteins;

}

sub get_mgf{
	#returns an array of hashes, hashes are keyed with each line of an mgf record and an extra one for spectra_peaks
	my @mgfs;	
	my $mgf_file = shift;
	local $/ = 'END IONS';
	#warn "Using a .mgf file $mgf_file\n";
	open FILE, "<$mgf_file" or die "Couldn't open $mgf_file .. !\n";

	#warn "spec is ", $spectrum, "\n";
	while (my $record = <FILE>){
		my %mgf;
		my @lines = split(/\n/,$record);
		my @spec;
		foreach my $line (@lines){

			if ($line =~ m/(.*)=(.*)/ ){ #we have a record line
				$mgf{$1} = $2;

			}
			elsif($line =~ m/(\d+\.\d+\s\d+\.\d+)/){
				push @spec, $line;

			}
		}
		my $spec = join("\n", @spec);
		$mgf{'spectra_peaks'} = $spec;
		push @mgfs, \%mgf;
	}
	close FILE;

	return @mgfs;
	
	
}

				
				
1;
