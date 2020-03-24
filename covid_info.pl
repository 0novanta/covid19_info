#!/usr/bin/perl

use LWP::Simple;
use feature qw(say);
use JSON;
use Text::Table;
use JSON::Parse ':all';
use Term::ReadKey;
use Data::Dumper;
use DateTime;

my $WEB_PAGE_ALL = "https://corona.lmao.ninja/all"; 
my $WEB_PAGE_COUNTRIES = "https://corona.lmao.ninja/countries";
my $raw_data;
my $parsed_json;


say "Select a country or write all for total count: ";
my $answer = <STDIN>;
chomp($answer);

if( $answer eq 'all'){
	all_info();
}
else{
	country_info();
	#say $address;
}

sub all_info{
	say "Retrieving data...";
	$raw_data = qx{curl --silent $WEB_PAGE_ALL};
	$parsed_json=parse_json($raw_data);
	my $dt = DateTime->new( year => 1970, time_zone => "UTC" );
	$dt->add( seconds => $parsed_json->{updated}/ 1000 );
	create_table($parsed_json->{cases}, $parsed_json->{deaths}, $parsed_json->{recovered});
	say "Last update on: " . $dt->strftime("%Y-%m-%d"); 
}

sub country_info{

	my $temp;
	my $var2;
	my $decoded;
	my $lc_answer;
	
	$lc_answer = lc($answer);
	#$raw_data = qx{curl --silent $address};
	my $json_file = qx{wget --quiet --output-document=countries_data.json $WEB_PAGE_COUNTRIES};
	
	{
    local $/ = undef;
    open my $fh, '<', 'countries_data.json';
    $temp = <$fh>;
    close $fh;
	}
	
	$decoded = decode_json($temp);
	
	for my $i ( @{$decoded} ){
		my $lcs = lc($i->{country});
		if($lcs eq $lc_answer){
			create_table($i->{cases}, $i->{deaths}, $i->{recovered});
		}
	}
	
}

sub create_table{
			
			my $tb = Text::Table->new(
		 		"Cases", "Deaths", "Recovered"
			);
			$tb->load(
		 		[$_[0], $_[1], $_[2]],
			);
			print $tb;	
}


