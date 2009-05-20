package PhosDB;

#################################
#
#module of methods for interacting with rails mysql database for TSL.phostools
#
#################################
use strict;
use Exporter;
use DBI;
use DBD::mysql;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 0.1;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(get_experiment_id get_organism_id insert_organism connect get_protein_id get_protein_id_from_fuzzy_accession insert_spectrum get_spectrum_id insert_phos_site get_phos_site_id insert_mascothit get_mascothit_id insert_phossites_spectrums update_spectrum insert_mascothits_proteins insert_spectrum_view insert_experiments_proteins insert_proteins_tissues insert_proteins_treatments insert_pfamhits_proteins insert_spectrums_spectrum_views get_spectrum_view_id get_go_term_id insert_go_term get_pfamhit_id insert_pfamdomain insert_pfamhit);
%EXPORT_TAGS = (DEFAULT => [qw()],
				ALL => [qw(get_experiment_id get_organism_id insert_organism connect get_protein_id get_protein_id_from_fuzzy_accession insert_spectrum get_spectrum_id insert_phos_site get_phos_site_id insert_mascothit get_mascothit_id insert_phossites_spectrums update_spectrum insert_mascothits_proteins insert_spectrum_view insert_experiments_proteins insert_proteins_tissues insert_proteins_treatments insert_pfamhits_proteins insert_spectrums_spectrum_views get_spectrum_view_id get_go_term_id insert_go_term get_pfamhit_id insert_pfamdomain insert_pfamhit)]						
);

sub connect{

	my $DataBaseName    =   "phosdb_development";
	my $DataBaseHost    =   "localhost";
	my $DataBaseUser    =   "root";
	my $DataBasePass    =   "";

	my $dbh = DBI->connect("DBI:mysql:database=$DataBaseName;host=$DataBaseHost",
	                                     "$DataBaseUser", 
	                                     "$DataBasePass",
	                                     { RaiseError => 1,
	                                       AutoCommit => 0 }) || die 
										"Unable to connect to $DataBaseHost because $DBI::errstr";
										
	return $dbh;	
	
	
}
sub get_organism_id{
	my $dbh = shift;
	my $binom_name = shift;
	my $common_name = shift;
	
	my $sql = "select id from organisms
	 						where 
						binomial_name  = '$binom_name'
						and
						common_name = '$common_name' ; ";
						
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $id = $sqlprepare->fetchrow_array();
	return $id;
	
}
sub get_experiment_id{
	my $dbh = shift;
	my $exp_name = shift;
	my $exp_description = shift;
	
	my $sql = "select id from experiments
	 						where 
						name  = '$exp_name'
						and
						description = '$exp_description' ; ";
						
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $id = $sqlprepare->fetchrow_array();
	return $id;	
}	
sub get_tissue_id{
	my $dbh = shift;
	my $organ = shift;
	my $cell_type = shift;
	my $sub_cell =shift;
	
	my $sql = "select id from tissues
	 						where 
						organ  = '$organ'
						and
						cell_type = '$cell_type'
						and
						sub_cell_loc = '$sub_cell' ; ";
						
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $id = $sqlprepare->fetchrow_array();
	return $id;
	
}
sub get_treatment_id{
	my $dbh = shift;
	my $growth = shift;
	my $age = shift;
	my $chem  = shift;
	my $abio = shift;
	
	my $sql = "select id from treatments
	 						where 
						growth_condition  = '$growth'
						and
						age = '$age'
						and 
						chemical_treatment = '$chem' 
						and 
						abiotic_treatment = '$abio' ; ";
						
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $id = $sqlprepare->fetchrow_array();
	return $id;
	
	
}

sub insert_experiment{
	my $dbh = shift;
	my $exp_name = shift;
	my $exp_description = shift;
	
	my $sql_exp = "insert into experiments (
											name, 
											description,
											pride_info_id, 
											mcp_info_id, 
											promex_info_id
											) values (
												'$exp_name',
												'$exp_description',
												'0',
												'0',
												'0'
											);";

	my $sqlprepare = $dbh->prepare($sql_exp);
	$sqlprepare->execute();
}
sub insert_treatment{
	my $dbh = shift;
	my $growth = shift;
	my $age = shift;
	my $chem = shift;
	my $abio = shift;
	
	my $sql = "insert into treatments (
										growth_condition,
										age,
										chemical_treatment,
										abiotic_treatment
											) values (
												'$growth',
												'$age',
												'$chem',
												'$abio'
											);";

	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();	
}	
	
sub insert_tissue{
	my $dbh = shift;
	my $organ = shift;
	my $cell_type = shift;
	my $sub_cell =shift;
	my $sql_tis = "insert into tissues (
										organ, 
										cell_type, 
										sub_cell_loc
										) values (
										'$organ',
										'$cell_type',
										'$sub_cell'
											);";

	my $sqlprepare = $dbh->prepare($sql_tis);
	$sqlprepare->execute();
	
}

sub insert_organism{
	my $dbh = shift;
	my $binom_name = shift;
	my $common_name = shift;
	my $sql = "insert into organisms ( binomial_name,
												 common_name
												) values (
													'$binom_name',
													'$common_name'

												);" ; 

	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();



}

sub insert_protein{
	my $dbh = shift;
	my $org_id = shift;
	my $accession = shift;
	my @tmp = split(/,/,$accession);
	$accession = $tmp[0];
	my $sequence_file = shift;
	my $sequence = '';
	my $description = '';
	use Bio::SeqIO;
	my $stream = Bio::SeqIO->new(-format=>'fasta', -file=>$sequence_file);
	while(my $seq_obj = $stream->next_seq() ){
		if ($seq_obj->id eq $accession){
			
			$sequence = $seq_obj->seq;
			$description = $seq_obj->description;
			$description =~ s/\'//g;
		}
		
	}
	die "no sequence to insert\n" unless $sequence;
	die "no description to insert\n" unless $description;
	my $sql = "insert into proteins (
									organism_id, 
									sequence, 
									accession, 
									description 
									) 
									values 
									(
										'$org_id', 
										'$sequence', 
										'$accession', 
										'$description'
									);"; 
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	
	
}

sub check_proteins_treatments{
	
	my $dbh = shift;
	my $protein_id = shift;
	my $treatment_id = shift;
	my $sql = "select protein_id from proteins_treatments where protein_id = '$protein_id' and treatment_id = '$treatment_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}

sub check_proteins_tissues{
	
	my $dbh = shift;
	my $protein_id = shift;
	my $tissue_id = shift;
	my $sql = "select protein_id from proteins_tissues where protein_id = '$protein_id' and tissue_id = '$tissue_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}

sub insert_mascothits_proteins{
	my $dbh = shift;
	my $mascothit_id = shift;
	my $protein_id = shift;
	my $sql = "insert into mascothits_proteins ( mascothit_id,
												 protein_id
												) values (
													'$mascothit_id',
													'$protein_id'
													
												);" ; 
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();	
}


sub check_pfamhits_proteins{
	
	my $dbh = shift;
	my $pfamhit_id = shift;
	my $protein_id = shift;
	my $sql = "select protein_id from pfamhits_proteins where pfamhit_id = '$pfamhit_id' and protein_id = '$protein_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}

sub check_mascothits_proteins{
	
	my $dbh = shift;
	my $mascothit_id = shift;
	my $protein_id = shift;
	my $sql = "select protein_id from mascothits_proteins where mascothit_id = '$mascothit_id' and protein_id = '$protein_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}

sub check_phossites_spectrums{
	
	my $dbh = shift;
	my $phossite_id = shift;
	my $spectrum_id = shift;
	my $sql = "select phossite_id from phossites_spectrums where phossite_id = '$phossite_id' and spectrum_id = '$spectrum_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}


sub check_experiments_proteins{
	
	my $dbh = shift;
	my $experiment_id = shift;
	my $protein_id = shift;
	
	my $sql = "select protein_id from experiments_proteins where protein_id = '$protein_id' and experiment_id = '$experiment_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}

sub check_goterms_proteins{
	
	my $dbh = shift;
	my $goterm_id = shift;
	my $protein_id = shift;
	
	my $sql = "select protein_id from goterms_proteins where protein_id = '$protein_id' and goterm_id = '$goterm_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}
sub check_spectrum_spectrumviews{
	my $dbh = shift;
	my $spectrum_id = shift;
	my $spectrumview_id = shift;
	
	my $sql = "select spectrum_id from spectrums_spectrumviews where spectrum_id = '$spectrum_id' and spectrumview_id = '$spectrumview_id'; ";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();
	my $result = $sqlprepare->fetchrow_array();
	return $result;
	
}



				sub insert_experiments_proteins{

					my $dbh = shift;
					my $experiment_id = shift;
					my $protein_id = shift;
					my $sql = "insert into experiments_proteins ( experiment_id,
																 protein_id
																) values (
																	'$experiment_id',
																	'$protein_id'

																);" ; 
					#	warn "$sql\n";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					#warn "$sql\n";


				}
				sub insert_proteins_tissues{
					my $dbh = shift;
					my $protein_id = shift;
					my $tissue_id = shift;
					my $sql = "insert into proteins_tissues ( protein_id,
																 tissue_id
																) values (
																	'$protein_id',
																	'$tissue_id'

																);" ; 
					#	warn "$sql\n";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					#warn "$sql\n";


				}
				sub insert_proteins_treatments{
					my $dbh = shift;
					my $protein_id = shift;
					my $treatment_id = shift;
					my $sql = "insert into proteins_treatments ( protein_id,
																 treatment_id
																) values (
																	'$protein_id',
																	'$treatment_id'

																);" ; 
					#	warn "$sql\n";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					#warn "$sql\n";


				}
				sub insert_pfamhits_proteins {
					my $dbh = shift;
					my $pfamhit_id = shift;
					my $protein_id = shift;
					my $sql = "insert into pfamhits_proteins (pfamhit_id,protein_id) values ('$pfamhit_id', '$protein_id');" ; 
					#warn $sql, "\n";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
				sub insert_spectrums_spectrum_views {
					my $dbh = shift;
					my $spec_id = shift;
					my $spectrum_view_id = shift;
					my $sql = "insert into spectrums_spectrumviews ( spectrum_id,
																 spectrumview_id
																) values (
																	'$spec_id',
																	'$spectrum_view_id'

																);" ; 

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
				sub get_spectrum_view_id{
					my $dbh = shift;
					my $spectrum_gif = shift;
					my $sql = "select id from spectrumviews where gif_file  = '$spectrum_gif'; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					my $result = $sqlprepare->fetchrow_array();
					return $result;

				}
				sub get_go_term_id{
					my $dbh = shift;
					my $goterm = shift;  
					my $goid = shift;
					my $aspect = shift;
					my $sql = "select id from goterms where goid = '$goid'; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					my $result = $sqlprepare->fetchrow_array();
					return $result;

				}
				sub insert_go_term{
					my $dbh = shift;
					my $goterm = shift;  $goterm =~ s/'//g; 
					my $goid = shift; 
					my $aspect = shift; 
					my $sql = "insert into goterms (term, goid, aspect) values ('$goterm', '$goid', '$aspect');";


					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
sub insert_goterms_proteins{
	my $dbh = shift;
	my $goterm_id = shift;
	my $protein_id = shift;
	
	my $sql = "insert into goterms_proteins ( protein_id,
												 goterm_id
												) values (
													'$protein_id',
													'$goterm_id'

												);" ; 
	#	warn "$sql\n";
	my $sqlprepare = $dbh->prepare($sql);
	$sqlprepare->execute();

	
	
}
				
				
sub get_pfamhit_id{
					my $dbh = shift;
					my $name = shift;
					my $start = shift;
					my $stop =shift;
					my $p = shift;
					my $sql = "select id from pfamhits where name = '$name' and
															start = '$start' and
															stop = '$stop' and
															p = '$p' ; " ;

				#	warn $sql, "\n";										
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					my $result = $sqlprepare->fetchrow_array();
					return $result;

}
				sub insert_pfamdomain {

					my $domain_id = shift;
					my $name = shift;
					my $dbh = shift;

					my $sql = "insert into pfamdomains (domainid, name) values ('$domain_id', '$name');";


					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
				sub insert_pfamhit {
					my $dbh = shift;
					my $name = shift;
					my $start = shift;
					my $stop = shift;
					my $p = shift;


					my $sql = "insert into pfamhits (
														name,
														start,
														stop,
														p
														) values (
														'$name',
														'$start',
														'$stop',
														'$p'
														);";

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
				sub insert_spectrum_view {
					my $dbh = shift;
					my $spectrum_gif = shift;

					my $sql = "insert into spectrumviews (
														gif_file
														) values (
															\"$spectrum_gif\"
														);";

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}


				sub update_spectrum{
					my $dbh = shift;
					my $spec_id = shift;
					die "no spec id\n" unless $spec_id;
					my $mascothit_id = shift;


					my $sql = "update spectrums set mascothit_id = '$mascothit_id' where id = '$spec_id' ;" ; 

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute(); 

				}
				sub insert_phossites_spectrums{
					my $dbh = shift;
					my $phos_id = shift;
					my $spec_id = shift;
					my $sql = "insert into phossites_spectrums ( phossite_id,
																 spectrum_id
																) values (
																	'$phos_id',
																	'$spec_id'

																);" ; 

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();


				}
				sub get_mascothit_id {
					my $dbh = shift;
					my $spectrum_id = shift;
					my $experiment_id = shift;
					my $tissue_id = shift;
					my $treatment_id = shift;
					my $mod_sequence = shift;
					my $start = shift;
					my $end = shift;
					my $measured_mz = shift;
					my $charge = shift;
					my $precursor_ion_mass = shift;
					my $calculated_mass = shift;
					my $delta_mass = shift;
					my $mascot_peptide_score = shift;
					my $xcorr= shift;
					my $delta_cn = shift;
					my $ms_level = shift;

					my $sql = "select id from mascothits where spectrum_id = '$spectrum_id' and 
																experiment_id = '$experiment_id' and
																tissue_id = '$tissue_id' and
																treatment_id = '$treatment_id' and
																mod_sequence = '$mod_sequence' and
																start = '$start' and
																end = '$end' and
																measured_mz = '$measured_mz' and
																charge = '$charge' and
																precursor_ion_mass = '$precursor_ion_mass' and
																calculated_mass = '$calculated_mass' and
																delta_mass =  '$delta_mass' and
																mascot_peptide_score = '$mascot_peptide_score' and
																xcorr = '$xcorr' and 
																delta_cn  = '$delta_cn' and
																ms_level = '$ms_level' ; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					my $result = $sqlprepare->fetchrow_array();
					#warn $sql, "\n";
					#warn $result, "\t=>mascot_hit_id\n";
					return $result;
				}
				sub insert_mascothit {
					my $dbh = shift;
					my $spectrum_id = shift;
					my $experiment_id = shift;
					my $tissue_id = shift;
					my $treatment_id = shift;
					my $mod_sequence = shift;
					my $start = shift;
					my $end = shift;
					my $measured_mz = shift;
					my $charge = shift;
					my $precursor_ion_mass = shift;
					my $calculated_mass = shift;
					my $delta_mass = shift;
					my $mascot_peptide_score = shift;
					my $xcorr= shift;
					my $delta_cn = shift;
					my $ms_level = shift;


					my $sql = "insert into mascothits (
														spectrum_id, 
														experiment_id, 
														tissue_id, 
														treatment_id, 
														mod_sequence,
														start,
														end,
														measured_mz,
														charge,
														precursor_ion_mass,
														calculated_mass,
														delta_mass,
														mascot_peptide_score,
														xcorr,
														delta_cn,
														ms_level
														) values (
														'$spectrum_id',
														'$experiment_id',
														'$tissue_id',
														'$treatment_id',
														'$mod_sequence',
														'$start',
														'$end',
														'$measured_mz',
														'$charge',
														'$precursor_ion_mass',
														'$calculated_mass',
														'$delta_mass',
														'$mascot_peptide_score',
														'$xcorr',
														'$delta_cn',
														'$ms_level'

														);";

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
				sub get_phos_site_id {
					my $dbh = shift;
					my $var = shift;
					my $p = shift;
					my $sql = "select id from phossites where variant = '$var' and p = '$p'; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					my $result = $sqlprepare->fetchrow_array();
				#	warn "id = $result var = $var\n";
					return $result;
				}
				sub insert_phos_site {
					my $dbh = shift;
					my $var = shift;
					my $p = shift;
					my $score = '';
					if (defined $p and $p != 0){
					 $score = -10 * log($p);
					}
					my $sql = "insert into phossites (
														variant,
														p,
														score
														) values (
															'$var',
															'$p',
															'$score'
														);";

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
				sub get_spectrum_id {
					my $dbh = shift;
					my $experiment_id = shift;
					my $tissue_id = shift;
					my $treatment_id = shift;
					my $spectrum_file = shift;
					my $sql = "select id from spectrums where spectrum_file  = '$spectrum_file'
														and experiment_id = '$experiment_id'
														and tissue_id = '$tissue_id'
														and treatment_id = '$treatment_id'; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					my $result = $sqlprepare->fetchrow_array();
					return $result;
				}
				sub insert_spectrum {
						my $dbh = shift;
						my $experiment_id = shift;
						my $tissue_id = shift;
						my $treatment_id = shift;
						my $spectrum_file = shift;
					my $sql = "insert into spectrums (
														experiment_id,
														tissue_id,
														treatment_id,
														spectrum_file
														) values (
														'$experiment_id',
														'$tissue_id',
														'$treatment_id',
														'$spectrum_file'
														);";

					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();

				}
				sub get_protein_id_from_fuzzy_accession {

					my $protein = shift;
					my $dbh = shift;
					my %protein_ids;

					my $sql = "select id from proteins where accession like '$protein\%';" ;
					#my $sql = "select id from proteins where accession  = '$protein'; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					while (my $result = $sqlprepare->fetchrow_array() ){

						$protein_ids{$result} = 1;

					}

					return %protein_ids;
				}
				sub get_protein_id {
					my $dbh = shift;
					my $accession = shift;
					my @tmp = split(/,/,$accession);
					$accession = $tmp[0];
					my $sql = "select id from proteins where accession  = '$accession'; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					my $result = $sqlprepare->fetchrow_array();
					return $result;
				}

				sub get_all_proteins {
					my $dbh = shift;
					my %protein_ids;
					my $sql = "select ID, accession from proteins";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					while (my ($id, $accession) = $sqlprepare->fetchrow_array() ){

						$protein_ids{$accession} = $id;

					}

					return %protein_ids;

				}

				sub get_proteins_with_goterms{
					my $dbh = shift;
					my %protein_ids;
					my $sql = "select protein_id from goterms_proteins; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					while (my $result = $sqlprepare->fetchrow_array() ){
						$protein_ids{$result} = 1;

					}
					return %protein_ids;

				}

				sub get_existing_go_terms{
					my %existing;
					my $dbh = shift;
					my $sql = "select * from goterms;" ; 
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					while (my @row = $sqlprepare->fetchrow_array()){
						#warn @row;
						my $termcomp = $row[1] . $row[2] . $row[3];
						#warn $termcomp;
						$existing{$termcomp} = 1;
					}

					return \%existing;

				}


				sub get_proteins_with_pfamhits{
					my $dbh = shift;
					my %protein_ids;
					my $sql = "select protein_id from pfamhits_proteins; ";
					my $sqlprepare = $dbh->prepare($sql);
					$sqlprepare->execute();
					while (my $result = $sqlprepare->fetchrow_array() ){
						$protein_ids{$result} = 1;

					}
					return %protein_ids;

				}
				
1;