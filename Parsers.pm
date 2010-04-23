package Parsers;


#################################
#
#module of methods for assisting with parsing files commonly used in proteomics db
#
#################################
use strict;
use Exporter;
use FileHandle;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 0.1;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(strip_whitespace_from_header);
%EXPORT_TAGS = (DEFAULT => [qw()],
				ALL =>[qw(strip_whitespace_from_header)]);
			
			
sub get_motifs_from_motifx { #gets the motifs from a motif_x html file
	my $file = shift;
	my %results;
	my $fh = new FileHandle;
	$fh->open($file, 'r');
	my $start = 0;
	my $motif = '';
	my $name;
	while (my $line = $fh->getline){
		next unless $line =~ m/\w/;
		chomp $line;
		if($line =~ m/<a name=".*">(.*)<\/a>/){
			$name = $1;
			$start = 1;
			next;
		}
		if ($name and $start){
			push @{$results{$name}}, $line;
		}
	}

		return %results;

}

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
sub get_pfam24hits{
	
	my $pfams = shift;
	open PFAMS, "<$pfams" || die "can't open PFAMS $pfams\n";
	my %pfams; 
	while (my $line = <PFAMS>){
		chomp $line;
		my @cell = split(/\s+/, $line);
			my $accession = $cell[0];
			my $start = $cell[1];
			my $stop = $cell[2];
			my $domainid = $cell[5];
			my $name = $cell[6];
			my $p = $cell[12];
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
		$description =~ s/\'//g;
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

=head1 NAME

Parsers - a module that includes code for reading files in formats commonly used in proteomics

=head1 AUTHOR

Dan MacLean (dan.maclean@tsl.ac.uk)

=head1 SYNOPSIS

	use PhosphoTools::Parsers;

	my $mgf_file = '/home/macleand/Desktop/my_recent_experiment.mgf';
	my @mgfs = Formatters::get_mgf($mgf_file);

=head1 DESCRIPTION

The Parsers module contains code for reading in various TSL and proteomics formats. Extra formats can be added on request. The module does not create objects like some of the other modules, rather its methods are accessed in the manner of subroutines in external files.

=head1 METHODS

=over

=item get_motifs_from_motifx(html_file)

Will read in all the motifs in a web page generated by the motif-x peptide motif finder and return a hash that has as a key the text
representation of the mofif and as a value an array of peptides that contain that motif.

	my $html = '/home/macleand/Desktop/motifx_output.htm';
	my %motifs = Parsers::get_motifs_from_motifx($html);

=item parse_phossites(ptm)

When provided with a PTM score line in format:

	PEP[T]IDESEQ : 0.005 ; PEPTIDE[S]EQ : 0.0000001 ; 

will return a hash with keys that are the peptide sequence and values that are the score for the PTM. This method exists as a number of older
scripts and data files encode the PTM in this manner

	my $ptm_line = 'PEP[T]IDESEQ : 0.005 ; PEPTIDE[S]EQ : 0.0000001 ;';
	my %ptms = Parsers::parse_phossites($ptm_line);

=item get_go_terms(go_slim_file)

When provided with a TAIR style GO SLIM GO annotation file, will return a hash with key of protein accession and a value of a hash with keys 
of a string of TERM ID ASPECT seperated by ';' 

	my $go_file = '/home/macleand/Desktop/TAIR9_GOSLIM';
	my %go_terms = Parsers::get_go_terms($go_file);

=item get_pfamhits(pfamscan_file)

When provided with a pfamscan output file, will return a hash with key of protein accession and a value of a hash with keys 
of a string of DOMAIN_NAME START STOP P_VALUE seperated by ';' 

	my $pfam_scan = '/home/macleand/Desktop/TAIR9_PFAMSCANS';
	my %pfams = Parsers::get_pfamhits($pfam_scan);


=item get_proteins(protein_fasta_file)

When provided with a Protein sequence FASTA format file, will return a hash with key of protein accession and a value of a hash with keys 
'sequence' which has the protein sequence and 'description' which holds a description. 

	my $proteins = '/home/macleand/Desktop/TAIR9.faa';
	my %proteins = Parsers::get_proteins($proteins);

=item get_mgf(mgf)

When provided with an MGF file, will return an array of hashes with key of each line of the mgf record 

	my $mgf = '/home/macleand/Desktop/my_mgf.mgf';
	my @mgfs = Parsers::get_mgf($mgf);


=back

=head1 SEE ALSO
PhosphoTools::Formatters; Bio::SeqIO;
