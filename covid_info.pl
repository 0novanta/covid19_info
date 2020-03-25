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
my $answer;

query();

sub query {
	say "Select a country or write all for total count: ";
	$answer = <STDIN>;
	chomp($answer);

	if( $answer eq 'all'){
		all_info();
	}
	else{
		country_info();
	}
}

sub all_info{
	say "Retrieving data...";
	$raw_data = qx{curl --silent $WEB_PAGE_ALL};
	
	if(defined $raw_data){
		$parsed_json=parse_json($raw_data);
		my $dt = DateTime->new( year => 1970, time_zone => "UTC" );
		$dt->add( seconds => $parsed_json->{updated}/ 1000 );
		create_table($parsed_json->{cases}, $parsed_json->{deaths}, $parsed_json->{recovered});
		say "Last update on: " . $dt->strftime("%Y-%m-%d"); 
	}
	else{
		die("Site is unreachable at the moment");
	}
	
	control_loop(1);	
	
}

sub country_info{

	my $temp;
	my $decoded;
	my $lc_answer;
	my $temp_flag = 0;
	
	$lc_answer = lc($answer);
	
	say "Retrieving data...";
	
	my $response = qx{wget --quiet --output-document=countries_data.json $WEB_PAGE_COUNTRIES};
	
	if(defined response){

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
				$temp_flag = 1;
				create_table($i->{cases}, $i->{deaths}, $i->{recovered});
			}
		}
		
		control_loop($temp_flag);
		
	}
	else{
		die("Site is unreachable at the moment");
	}
	
}

sub control_loop(){
	my $flag = 0;
	
	$flag = $_[0];
	
	if($flag == 0){
		say "$answer is not a valid option, try again:";
		query();
	}
	else{
		say "Press r to repeat or e to exit";
 		$answer = <STDIN>;
 		chomp($answer);
		while($answer ne 'r'){
			if($answer eq 'e'){
				exit 1;
			}
			else{
				say "That's not a valid option, try again:";
				$answer = <STDIN>;
				chomp($answer);
			}
		}
		query(); 
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
