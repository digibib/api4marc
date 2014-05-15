#!/usr/bin/perl

use ZOOM;
use MARC::Record;
use MARC::File::XML;
use MARC::File::USMARC;
use YAML qw(LoadFile);
use Data::Dumper;
use Mojolicious::Lite;

# read config
my $config = YAML::LoadFile('config.yaml');

get '/' => sub {
  my $self = shift;
  my $apikey     = $self->param('apikey');
  my $base       = $self->param('base') || die 'No base specified!';
  my $format     = $self->param('format') || 'usmarc';
  my $maxRecords = $self->param('maxRecords') || 10;
  my $query      = $self->param('query') || die 'No query specified!';

if (!exists $config{$base}) {
    die 'Invalid base supplied!'
} 
#ZOOM::Log::init_file("./zoom.log");
my $conn = new ZOOM::Connection($config->{$base}->{url});
  $conn->option(preferredRecordSyntax => $format);
  $conn->option(user => $config->{$base}->{user}) if $config->{$base}->{user};
  $conn->option(pass => $config->{$base}->{pass}) if $config->{$base}->{pass};
#print("server is '", $conn->option("serverImplementationName"), "'\n");
if ($conn->errcode() != 0) {
  die("somthing went wrong: " . $conn->errmsg())
}

# Query handling
my $rs = $conn->search_pqf('@attr 1=7 978-178-005-109-3');
my $n = $rs->size();
#print "Found ", $n, " records\n";
my $xml = MARC::File::XML::header();
for my $i (1 .. $n) {
   my $rec = $rs->record($i-1);
   my $raw = $rec->raw();
   my $marc = new_from_usmarc MARC::Record($raw);
   $marc->encoding("UTF-8");
   $xml .= MARC::File::XML::record( $marc );
   #print $marc->as_xml_record();
}
$xml .= MARC::File::XML::footer();

#print $xml;
$conn->destroy();
$self->render(text => $xml);
};

app->start;
