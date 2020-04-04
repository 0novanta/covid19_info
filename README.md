# covid19_info
Simple Perl script to check info about Covid19 cases, deaths, recovered around the world and for each country.

It takes data from https://corona.lmao.ninja/countries and https://corona.lmao.ninja/all (they seem to be down sometimes), those sheets take their data from https://www.worldometers.info/coronavirus/

To run the program go to terminal and run: 'perl info_covid.pl' 
Alternativelym, make it executable by running: 'chmod +x covid_info.pl' and then run it with './covid_info.pl'.

If you select a country (by writing the country name as input when asked) it will download data from the https://corona.lmao.ninja/countries and save it as json file (called countries_data.json), in the same folder of the program.

You can pass the following arguments after 'perl info_covid.pl':
- '-e' to show in alphabetical order every european country with their stats;
- '-eC' to show in cases order every european country;

You will need to install:
- Text::Table https://metacpan.org/pod/Text::Table
- JSON::Parse https://metacpan.org/pod/JSON::Parse
- DateTime https://metacpan.org/pod/DateTime
