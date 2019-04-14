#!/usr/bin/perl
use lib qw(/volume/labtools/lib/);
use SysTest::DB;
use Storable;
use Data::Dumper;
use LWP::Simple;
use HTTP::Request;
use HTML::TableExtract;
set_dsn('pg_regressd');
my $dlmt = ":&:";
my $hostname = 'eabu-systest-db.juniper.net';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=regression;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
			@data = `cat 3`;
			foreach $d(@data)
			{
				chomp($d);
				@vals = split("-",$d);
				$query ="update new_script_map set profiles='$vals[1]',subdomains='$vals[2]' where id='$vals[0]'";
				print "$query \n";
				my $sth=$dbh->prepare($query);
				$sth->execute;
	}
