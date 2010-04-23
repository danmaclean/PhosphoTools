package QuantitativeExperiment;
use strict;
use Exporter;
use PhosphoTools::Measurement;
use Statistics::Descriptive;
use Text::xSV ;
use POSIX;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 0.1;
@ISA = qw();
@EXPORT = ();
@EXPORT_OK = qw();
%EXPORT_TAGS = (DEFAULT => [qw()],
				ALL =>[qw()]);

sub new{
	my $class = shift;
	my %arg;
	###very messily go through the args array and set up an easier hash..... 
	for (my $i = 0; $i< scalar(@_); ++$i){
		if ($_[$i] eq '-file'){
			$arg{'-file'} = $_[$i+1];

		}
		if ($_[$i] eq '-label'){
			$arg{'-label'} = $_[$i+1];

		}		
	}
	
	my $csv = new Text::xSV ;
	$csv->open_file($arg{'-file'}) || die "cant find file $arg{'-file'}\n\n";
	$csv->read_header();
	
	foreach my $field ($csv->get_fields){
		if (lc($field) ne $field){
			$csv->alias($field, lc($field));
		}
	}


	my $self = {}; 
	
	my $meas_id = 1;
	while ($csv->get_row){

		my ($sample_name, $biol_rep, $tech_replicate, $timepoint, $accession, $score, $mass, $protein_ratio, $sd, $nos_pep, $description, $pep_hit_no, $z, $seq, $cleavage, $pep_ratio, $pep_sd, $pep_fraction, $pep_correlation, $intensity, $modification) = $csv->extract( qw(sample_name biol_rep tech_replicate timepoint accession score mass protein_ratio sd nos_pep description pep_hit_no z seq cleavage pep_ratio pep_sd pep_fraction pep_correlation intensity modification) ); 

		my $measurement = Measurement->new(
		'-sample_name' => $sample_name,
		'-biol_rep' => $biol_rep,
		'-tech_replicate' => $tech_replicate,
		'-timepoint' => $timepoint,
		'-accession' => $accession,
		'-score' => $score,
		'-mass' => $mass,
		'-protein_ratio'=> $protein_ratio,
		'-sd' => $sd,
		'-nos_pep' => $nos_pep,
		'-description' => $description,
		'-pep_hit_no' => $pep_hit_no,
		'-z' => $z,
		'-seq' => $seq,
		'-cleavage' => $cleavage,
		'-pep_ratio' => $pep_ratio,
		'-pep_sd' => $pep_sd,
		'-pep_fraction' => $pep_fraction,
		'-pep_correlation' => $pep_correlation,
		'-intensity' => $intensity,
		'-modification' => $modification);
		$$self{'measurements'}{$meas_id} = $measurement;
		$meas_id++;
	}
	
	bless $self, $class;
}
sub measurement_total{
	my $self = shift;
	return scalar keys %{$$self{'measurements'}} ;
}
sub normalise_by_pep_ratio{
	my $self = shift;
	my @pep_ratios = $self->pep_ratios;
	my $median = median(\@pep_ratios);
	foreach my $meas (keys %{$$self{'measurements'}}){
		my $norm_pep_ratio = $$self{'measurements'}{$meas}->pep_ratio / $median;
		$$self{'measurements'}{$meas}->_set_norm_pep_ratio($norm_pep_ratio);

	}
}
sub log_pep_ratio{
	my $self = shift;
	my $base = shift;

	foreach my $meas (keys %{$$self{'measurements'}}){
		my $log_pep_ratio = $$self{'measurements'}{$meas}->log_pep_ratio($base);
		$$self{'measurements'}{$meas}->_set_norm_pep_ratio($log_pep_ratio);

	}
}
sub measurement_list{
	my $self = shift;
	my @measurements;
	foreach my $measurement (keys %{$$self{'measurements'}}){
		push @measurements, $$self{'measurements'}{$measurement};
	}
	return @measurements;
}
sub norm_pep_ratios{
	my $self = shift;
	my @norm_pep_ratios;
	foreach my $measurement ($self->measurement_list){
		push @norm_pep_ratios, $measurement->norm_pep_ratio; 
	}
	return @norm_pep_ratios;
}
sub pep_ratios{
	my $self = shift;
	my @pep_ratios;
	foreach my $measurement ($self->measurement_list){
		push @pep_ratios, $measurement->pep_ratio; 
	}
	return @pep_ratios;
}
sub write_data{
	my $self = shift;
	print Measurement::_table_header, "\n";
	foreach my $measurement ($self->measurement_list){
		print $measurement->write_measurement, "\n";
	}
}
sub median{
	my @vals = @{$_[0]};
	#foreach my $v (@vals){ print " $v";}
	#print "\n";
	#warn scalar(@vals) % 2, "\n";
	if (scalar(@vals) % 2 == 1){
		
		my $mid_val = floor(scalar(@vals) / 2);
		#warn "odd ", $vals[$mid_val];		
		return $vals[$mid_val];

	}
	else{
		
		my $left_val = scalar(@vals) / 2;
		my $right_val = (scalar(@vals) / 2) + 1;
		#warn "even ", $vals[$left_val] + $vals[$right_val] / 2;
		return (($vals[$left_val] + $vals[$right_val]) / 2);

	}
	
}
1;