package Measurement;
use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 0.1;
@ISA = qw();
@EXPORT = ();
@EXPORT_OK = qw();
%EXPORT_TAGS = (DEFAULT => [qw()],
				ALL =>[qw()]);
use Data::Dumper;

sub new {
    my $ref = shift;
    my $class = ref($ref) || $ref;
	my ($sample_name, $biol_rep, $tech_replicate, $timepoint, $accession, $score, $mass, $protein_ratio, $sd, $nos_pep, $description, $pep_hit_no, $z, $seq, $cleavage, $pep_ratio, $pep_sd, $pep_fraction, $pep_correlation, $intensity, $modification);

	for (my $i = 0; $i< scalar(@_); ++$i){
		next unless defined $_[$i];
		if ($_[$i] eq '-sample_name'){
			$sample_name = $_[$i+1];
		}
		if ($_[$i] eq '-biol_rep'){
			$biol_rep = $_[$i+1];
		}
		if ($_[$i] eq '-tech_replicate'){
			$tech_replicate = $_[$i+1];
		}
		if ($_[$i] eq '-timepoint'){
			$timepoint = $_[$i+1];
		}
		if ($_[$i] eq '-accession'){
			$accession = $_[$i+1];
		}
		if ($_[$i] eq '-score'){
			$score = $_[$i+1];
		}
		if ($_[$i] eq '-mass'){
			$mass = $_[$i+1];
		}
		if ($_[$i] eq '-protein_ratio'){
			$protein_ratio = $_[$i+1];
		}						
		if ($_[$i] eq '-sd'){
			$sd = $_[$i+1];
		}
		if ($_[$i] eq '-nos_pep'){
			$nos_pep = $_[$i+1];
		}
		if ($_[$i] eq '-description'){
			$description = $_[$i+1];
		}
		if ($_[$i] eq '-pep_hit_no'){
				$pep_hit_no = $_[$i+1];
			}
		if ($_[$i] eq '-z'){
				$mass = $_[$i+1];
			}
		if ($_[$i] eq '-seq'){
				$seq = $_[$i+1];
			}
		if ($_[$i] eq '-cleavage'){
				$cleavage = $_[$i+1];
			}
	
		if ($_[$i] eq '-pep_ratio'){
				$pep_ratio = $_[$i+1];
			}
		if ($_[$i] eq '-pep_sd'){
				$pep_sd = $_[$i+1];
			}
		if ($_[$i] eq '-pep_fraction'){
				$pep_fraction = $_[$i+1];
			}
		if ($_[$i] eq '-pep_correlation'){
				$pep_correlation = $_[$i+1];
			}
		if ($_[$i] eq '-intensity'){
				$intensity = $_[$i+1];
			}
		if ($_[$i] eq '-modification'){
				$modification = $_[$i+1];
			}
		
		
	}


    my $self = {
		'sample_name' => $sample_name,
		'biol_rep' => $biol_rep,
		'tech_replicate' => $tech_replicate,
		'timepoint' => $timepoint,
		'accession' => $accession,
		'score' => $score,
		'mass' => $mass,
		'protein_ratio'=> $protein_ratio,
		'sd' => $sd,
		'nos_pep' => $nos_pep,
		'description' => $description,
		'pep_hit_no' => $pep_hit_no,
		'z' => $z,
		'seq' => $seq,
		'cleavage' => $cleavage,
		'pep_ratio' => $pep_ratio,
		'pep_sd' => $pep_sd,
		'pep_fraction' => $pep_fraction,
		'pep_correlation' => $pep_correlation,
		'intensity' => $intensity,
		'modification' => $modification,
		'norm_ratio' => undef
	};

    bless $self, $class;
}
sub sample_name {
	my $self = shift;
	return $$self{'sample_name'};
}
sub biol_rep {
	my $self = shift;
	return $$self{'biol_rep'};
}
sub tech_replicate {
	my $self = shift;
	return $$self{'tech_replicate'};
}
sub timepoint {
	my $self = shift;
	return $$self{'timepoint'};
}
sub accession {
	my $self = shift;
	return $$self{'accession'};
}
sub score {
	my $self = shift;
	return $$self{'score'};
}
sub mass {
	my $self = shift;
	return $$self{'mass'};
}
sub protein_ratio {
	my $self = shift;
	return $$self{'protein_ratio'};
}
sub sd {
	my $self = shift;
	return $$self{'sd'};
}
sub nos_pep {
	my $self = shift;
	return $$self{'nos_pep'};
}
sub description {
	my $self = shift;
	return $$self{'description'};
}
sub pep_hit_no {
	my $self = shift;
	return $$self{'pep_hit_no'};
}
sub z {
	my $self = shift;
	return $$self{'z'};
}
sub seq {
	my $self = shift;
	return $$self{'seq'};
}
sub cleavage {
	my $self = shift;
	return $$self{'cleavage'};
}
sub pep_ratio {
	my $self = shift;
	return $$self{'pep_ratio'};
}
sub pep_sd {
	my $self = shift;
	return $$self{'pep_sd'};
}
sub pep_fraction {
	my $self = shift;
	return $$self{'pep_fraction'};
}
sub pep_correlation {
	my $self = shift;
	return $$self{'pep_correlation'};
}
sub intensity {
	my $self = shift;
	return $$self{'intensity'};
}
sub modification {
	my $self = shift;
	return $$self{'accession'};
}
sub _set_norm_pep_ratio {
	my $self = shift;
	my $val = shift;
	$$self{'norm_pep_ratio'} = $val;
}
sub norm_pep_ratio {
	my $self = shift;
	return	$$self{'norm_pep_ratio'};
}
sub log_pep_ratio{
	my $self = shift;
	my $base = shift;
	my $logged = logx($self->norm_pep_ratio, $base);
	$self->_set_norm_pep_ratio($logged);
}
sub logx {
	my $n = shift;
	my $base = shift;
 	return log($n)/log($base);
 }
sub write_measurement{
	my $self = shift;
	my @headers = headers();
	my $string = '';
	foreach my $header (@headers){
		$string = $string . $self->$header . ',';
	}
	$string = $string . $self->norm_pep_ratio;
}
sub headers{
	return qw(sample_name biol_rep tech_replicate timepoint accession score mass protein_ratio sd nos_pep description pep_hit_no z seq cleavage pep_ratio pep_sd pep_fraction pep_correlation intensity modification); 
}
sub _table_header{
	my @headers = headers();
	my $string = join(',',@headers);
	$string = $string . ',norm_pep_ratio';
	return $string; 
}
1;