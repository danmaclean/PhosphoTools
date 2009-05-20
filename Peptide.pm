package Peptide;
###################
#
#Nascent class for peptide object, not sure about usefullness of object for peptide yet, so not finished
#
###################
use strict;
use Exporter;
use Text::xSV;
use Data::Dumper;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = 0.1;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw();
%EXPORT_TAGS = (DEFAULT => [qw()],
				ALL =>[qw()]);


sub new{
	my $class = shift;
	my %params = @_;

	my $self = {};
	bless($self, $class);
	$self->{file} = $params{file};
	$self->{format} = $params{format};
	$self->{lines_read} = 0;
	return $self;
	
}

sub file{
	my $self = shift;
	if (@_){$self->{file} = shift}
	return $self->{file};

}


sub format{
	my $self = shift;
	if (@_) { $self->{format} = shift; }
    return $self->{format};
    
}

sub next_pep{
	my $self = shift;
	warn $self->file, "\n";
	my $file = '/Users/macleand/Desktop/geneXnets.py';
	open FILE, $self->file || die "cant open $self->file\n";
	while (my $line = <FILE>){
		
		return $line;
		
	}

}


