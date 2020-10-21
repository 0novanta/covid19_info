#!/usr/bin/perl
our $VERSION = '5.28.2';

#Dependencies;
use feature qw(say);
use JSON;
use Text::Table;
use JSON::Parse ':all';
use DateTime;

my $WEB_PAGE_ALL = "https://corona.lmao.ninja/v3/covid-19/all"; 
my $WEB_PAGE_COUNTRIES = "https://corona.lmao.ninja/v3/covid-19/countries";
my @european_countries = ( "Austria",
"Belgium",
"Bulgaria",
"Croatia",
"Cyprus",
"Czech Republic",
"Denmark",
"Estonia",
"Finland",
"France",
"Germany",
"Greece",
"Hungary",
"Ireland",
"Italy",
"Latvia",
"Lithuania",
"Luxembourg",
"Malta",
"Netherlands",
"Poland",
"Portugal",
"Romania ",
"Slovakia",
"Slovenia",
"Spain",
"Sweden" );

my $raw_data;
my $parsed_json;
my $answer;
my $argv_flag = 0;

query();

#selection subroutine;
sub query {
	
	if($argv_flag == 0){
		if($ARGV[0] eq '-e'){
			european_countries_proc();
			$argv_flag = 1;
		}
		elsif($ARGV[0] eq '-eC'){
			european_countries_in_order_proc();
			$argv_flag = 1;
		}
	}
	
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

#-eC processing subroutine
sub european_countries_in_order_proc{
	
	my $response = qx{wget --quiet --output-document=countries_data.json $WEB_PAGE_COUNTRIES};
	my @eu_countries;
	my @ordinated_eu_countries;
	my @cases;
	my $tb = Text::Table->new(
		 		"Country", "Cases", "Deaths", "Recovered"
			);
	
	if(defined response){
		{
		 local $/ = undef;
		 open my $fh, '<', 'countries_data.json';
		 $temp = <$fh>;
		 close $fh;
		}
		$decoded = decode_json($temp);	
	}
	
	for(my $i=0; $i<@european_countries; $i++){
		for my $k ( @{$decoded} ){
			if($european_countries[$i] eq $k->{country}){
				push(@eu_countries, $k->{country});
				push(@eu_countries, $k->{cases});
				push(@cases, $k->{cases});
				push(@eu_countries, $k->{deaths});
				push(@eu_countries, $k->{recovered});
			}
		}
	}
	
	@sorted_cases = sort compare_sort @cases;
	
	for(my $i=0; $i<scalar(@sorted_cases); $i++){
		for(my $k=1; $k<scalar(@eu_countries); $k=$k+4){
			if($sorted_cases[$i] == $eu_countries[$k]){
				$tb->load(
		 		[$eu_countries[$k-1], $eu_countries[$k], $eu_countries[$k+1], $eu_countries[$k+2]],
				);
			}
		}	
	}
	
	print $tb;
	say ' ';
}

sub compare_sort 
{ 
   if($a > $b) 
   { 
      return -1; 
   } 
   elsif($a == $b) 
   { 
      return 0; 
   } 
   else
   { 
      return 1;                        
   } 
} 

#-e processing subroutine
sub european_countries_proc{

	my $response = qx{wget --quiet --output-document=countries_data.json $WEB_PAGE_COUNTRIES};
	
	my $tb = Text::Table->new(
		 		"Country", "Cases", "Deaths", "Recovered"
			);
	
	if(defined response){
		{
		 local $/ = undef;
		 open my $fh, '<', 'countries_data.json';
		 $temp = <$fh>;
		 close $fh;
		}
		$decoded = decode_json($temp);	
	}

	for(my $i=0; $i<@european_countries; $i++){
		for my $k ( @{$decoded} ){
			if($european_countries[$i] eq $k->{country}){
				$tb->load(
		 		[$k->{country}, $k->{cases}, $k->{deaths}, $k->{recovered}],
				);
			}
		}
	}
	
	print $tb;
	say ' ';
		
}

#'all' option processing subroutine;
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

#single country processing subroutine;
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

#control loop on given input subroutine;
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

#table creation subroutine
sub create_table{
			
			my $tb = Text::Table->new(
		 		"Cases", "Deaths", "Recovered"
			);
			$tb->load(
		 		[$_[0], $_[1], $_[2]],
			);
			print $tb;	
}
