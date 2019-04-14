#!/usr/bin/perl
use HTML::TableExtract;
use Data::Dumper;
use DBI;
use POSIX;
### Db connection 
my $hostname = 'eabu-systest-db.juniper.net';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=regression;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
# DB-RM
$release = $ARGV[0];
$func = $ARGV[1];
%hash = ();
#### Select the DR ids from the configuration
my $query = "select drids,milestone from fpconfig where releasename='$release' and function='$func'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
    foreach my $ar(@{$r})
    {
        $hash{$ar->{milestone}} = $ar->{drids};
    }
### get the frist Pass order
my $query = "select ord from firstpassorder where function='$func'";
@ord = ();
my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
    foreach my $ar(@{$r})
    {
		@ord = split(',',$ar->{ord});
}
%first_pass = ();
foreach $miles(sort keys %hash)
{
	$drs = $hash{$miles};
	@drids = split(",",$drs);
	$totalfirstrunscript = 0;
	$totalfirstrunpass = 0;
	foreach $drid(@drids)
	{
		chomp($drid);
		print "$miles , $drid \n";
		$url = "wget -o log -O out --http-user=sooraj --http-password=budwiser_1234 \"http://systest.juniper.net/ti/webapp/dr/debug_dr/index.mhtml?mode=5:7:0&result_id=$drid\"";
    $out  = `$url`;
    $out = `grep  -a "First Run Raw Pass Rate.*(excluding transition scripts)" out`;
    ($scriptstats) = $out =~ /\((.*?)\)/;
    ($firstrunpass) = $scriptstats =~ /(.*)\//;
    ($firstrunscript) = $scriptstats =~ /\/(.*)/;
	$totalfirstrunscript += $firstrunscript;
    $totalfirstrunpass += $firstrunpass;
	}
	$first_pass{$miles} = sprintf "%.2f",($totalfirstrunpass / $totalfirstrunscript ) * 100;
}
$buff="<tr><td>$release <img class=''trends'' src=''/Regression/report/new/images/trend.jpg'' width=''20px'' height=''20px'' Title=''Trend Chart'' onclick=''javascript:loadfirstpasschart(\"$release\",\"$func\");''/></td>";
foreach $mile(@ord)
{
	if(exists $first_pass{$mile}){ $buff .= "<td>$first_pass{$mile}</td>";} else { $buff .= "<td>NA</td>";}
}
$buff .= "</tr>";
#### update the table
$query = "delete from firstpassres where function='$func' and release='$release'";
my $sth=$dbh->prepare($query);
    $sth->execute;
$query = "insert into firstpassres values('$func','$release','$buff')";
my $sth=$dbh->prepare($query);
$sth->execute;

