#!/usr/bin/perl

use ZOOM;
use MARC::Record;
#use MARC::File::XML;
use MARC::File::XML ( BinaryEncoding => 'utf8', RecordFormat => 'UNIMARC' );
use MARC::File::USMARC;
use YAML qw(LoadFile);
use Data::Dumper;
use Mojolicious::Lite;
use Switch;

# read config
my $config = YAML::LoadFile('config.yaml');

#z3950 queries
use constant {
    TITLE     => "\@attr 1=4",
    ISBN      => "\@attr 1=7",
    AUTHOR    => "\@attr 1=1003",
    EAN       => "\@attr 1=1016",
  };

get '/' => sub {
  my $self = shift;
  my $base       = $self->param('base') || return $self->render(text => 'Missing base param!', status => 400);
  my $format     = $self->param('format') || 'USMARC';
  my $maxRecords = $self->param('maxRecords') || 10;
  
  return $self->render(text => 'Invalid base supplied!', status => 400) unless (exists $config->{bases}->{$base});

  # building query
  my %query = ();
  $query{'isbn'}   = $self->param('isbn') if $self->param('isbn');
  $query{'ean'}    = $self->param('ean') if $self->param('ean');
  $query{'title'}  = $self->param('title') if $self->param('title');
  $query{'author'} = $self->param('author') if $self->param('author');

  # Query handling
  my $querystr;
  switch (%query) {
    case 'isbn'   { $querystr = "@{[ISBN]} $query{isbn}" }
    case 'ean'    { $querystr = "@{[EAN]} $query{ean}" }
    case 'title'  { $querystr = "@{[TITLE]} \"$query{title}\"" }
    case 'author' { $querystr = "@{[AUTHOR]} \"$query{author}\"" }
  }
  return $self->render(text => 'No valid query params given!', status => 400) unless ($querystr);
  # connecting to external base  
  my $conn = new ZOOM::Connection($config->{bases}->{$base}->{host}, 
          $config->{bases}->{$base}->{port},
          databaseName => $config->{bases}->{$base}->{db},
          preferredRecordSyntax => $format,
          user => $config->{bases}->{$base}->{user},
          pass => $config->{bases}->{$base}->{pass},
          charset => "UTF-8"); # request unicode encoding

  $self->app->log->debug("Logged in to server $config->{bases}->{$base}->{host}: "
    . $conn->option("serverImplementationName"));

  if ($conn->errcode() != 0) {
    $self->app->log->error("Error connecting to external base: " . $conn->errmsg() );
    return $self->render(text => 'Error connecting to external base:\n' . $conn->errmsg(), status => 500);
  }

  my $rs = $conn->search_pqf($querystr);
  my $n = $rs->size();
  $self->app->log->debug("Querystring: $querystr.");
  $self->app->log->debug("Number of records found: $n. maxRecords: $maxRecords");
  return $self->render(text => 'No records found.', status => 404) unless ($n);

  my $xml = MARC::File::XML::header();
  for my $i (1 .. $n) {
     my $rec = $rs->record($i-1);
     my $raw = $rec->raw();

    # force leader pos 09 to be 'a', meaning that encoding is indeed unicode, as requested above
    substr($raw, 9, 1, 'a');

     my $marc = MARC::Record->new_from_usmarc($raw);
     $xml .= MARC::File::XML::record( $marc );
     last if $i >= $maxRecords;
  }
  $xml .= MARC::File::XML::footer();

  #print $xml;
  $conn->destroy();
  $self->render(text => $xml, status => 200, format => 'xml');
};

app->types->type(xml => 'application/xml; charset=UTF-8');
app->secrets($config->{appsecret});
app->log->level('error');
app->start;
