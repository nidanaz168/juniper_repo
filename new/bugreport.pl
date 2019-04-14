#!/usr/bin/perl
use lib qw(/homes/rpathak/public_html/EABU/Release/PRS/shared /homes/rpathak/public_html/EABU/RLI /volume/labtools/lib /volume/labtools/eabu/lib/Dashboard );
use HTML::TableExtract;
use Data::Dumper;
use DBI;
use POSIX;
use Date::Calc;
use Date::DE qw(holidays);
use Date::Business;
### Db connection 
my $hostname = 'eabu-systest-db.juniper.net';
my $user = "postgres";
my $pass = "postgres";
my $port = "5432";
my $dsn = "dbi:Pg:database=regression;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn,$user,$pass)
                or die "Couldn't connect to database ".DBI->errstr;
$gnats_prefix = "https://gnats.juniper.net/web/default/do-query?adv=0&prs=";
$gnats_postfix = "&csv=0&columns=synopsis%2Creported-in%2Csubmitter-id%2CRc-Test-Gap-Owner%2CTest-Gap-Analysis-Status%2Cproduct%2Cclass%2Ccategory%2Cproblem-level%2Cblocker%2Cplanned-release%2Cstate%2Cresponsible%2Coriginator%2Carrival-date%2Cdev-owner%2Cfix-eta%2Clatest-summary-status&op=%26";
### First get the active releases
%releasemap = ();
$release = $ARGV[0];
$querystr = "";
$today = `date  "+%Y-%m-%d"`;
$query = "select plannedrelease,milestone from fpconfig where releasename='$release' and function='MMX'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
    foreach my $ar(@{$r})
    {
		$querystr .= "$ar->{plannedrelease}|";
		$releasemap{$ar->{plannedrelease}}{new} = 0;
		$releasemap{$ar->{plannedrelease}}{newprs} = "";
		$releasemap{$ar->{plannedrelease}}{old} = 0;
		$releasemap{$ar->{plannedrelease}}{oldprs} = "";
		$releasemap{$ar->{plannedrelease}}{fixed} = 0;
		$releasemap{$ar->{plannedrelease}}{fixedprs} = "";
		$releasemap{$ar->{plannedrelease}}{milestone} = $ar->{milestone};
		
	}
@plrelarr = keys %releasemap;
foreach $rel(sort @plrelarr)
{
    #### Get the milestone from milestone table
    $query = "select enddate from milestones  where release='$release' and minor='$rel'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
     my $r=$sth->fetchall_arrayref({});
    $release_date = "";
    foreach my $ar(@{$r})
    {
        $releasemap{$rel}{reldate} = $ar->{enddate};
    }
}
chop($querystr);
print "$querystr \n";
$prbuffer = "<table style='width:50%'><thead><tr><th>Number</th><th>Dev-Owner</th><th>Responsible</th><th>Originator</th><th>Created</th><th>Closed-Date</th><th>Feedback-Date</th><th>Planned-Release</th><th>State</th><th>Blocker</th><th>Problem-Level</th><th>Attributes</th><th>Reported-In</th><th>Product</th><th>Submitter-Id</th><th>Customer</th><th>Resolution</th></tr></thead>";
	@prs = `/usr/local/bin/query-pr  --expr '(planned-release  ~ "$querystr") & ((dev-owner['bu'] == "psd-rbu") | (responsible['bu'] == "psd-rbu")) & (Attributes ~ "regression-pr")'  --format '"%s:&:&:%s:&:&:%s:&:&:%s:&:&:%Q:&:&:%Q:&:&:%Q:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:%s:&:&:" Number Dev-Owner Responsible Originator Created Closed-Date Feedback-Date Planned-Release State Blocker Problem-Level Attributes Reported-In  Product Submitter-Id Customer Resolution'`;	
%prhash_swbeh = ();
foreach $pr(@prs)
{
		@tmp = split(":&:&:",$pr);
		($prnoscope) = $tmp[0] =~ /(.*)-/;
		($scope) = $tmp[0] =~ /-(.*)/;
		chomp($scope);
		$actrel = getactrel($tmp[7]);
		if($scope == 1)
		{
			if(exists $releasemap{$actrel}{new}) { $releasemap{$actrel}{new}++;$releasemap{$actrel}{newprs} .= "+$tmp[0]";}
			else { $releasemap{$actrel}{new} = 1; $releasemap{$actrel}{newprs} = "$tmp[0]";}
		}
		else
		{		
			if(exists $releasemap{$actrel}{old}) { $releasemap{$actrel}{old}++;$releasemap{$actrel}{oldprs} .= "+$tmp[0]";}
			else { $releasemap{$actrel}{old} = 1; $releasemap{$actrel}{oldprs} = "$tmp[0]";}
		}
		if($tmp[16] =~ /^fixed$|^fixed-elswhere$/)
		{
			if(exists $releasemap{$actrel}{fixed}) { $releasemap{$actrel}{fixed}++;$releasemap{$actrel}{fixedprs} .= "+$tmp[0]";}
			else { $releasemap{$actrel}{fixed} = 1; $releasemap{$actrel}{fixedprs} = "$tmp[0]";}
		}
		### Check dates For PRs That are still opne after reelase date
		if((checkDate($today,$releasemap{$actrel}{reldate}) == 0) && ($tmp[8] =~ /open|info|analyzed/))
		{
			if(exists $releasemap{$actrel}{open}) { $releasemap{$actrel}{open}++;$releasemap{$actrel}{openprs} .= "+$tmp[0]";}
			else { $releasemap{$actrel}{open} = 1; $releasemap{$actrel}{openprs} = "$tmp[0]";}
		}
			
		
			if(exists $releasemap{$actrel}{total}) { $releasemap{$actrel}{total}++;$releasemap{$actrel}{totalprs} .= "+$tmp[0]";}
			else { $releasemap{$actrel}{total} = 1; $releasemap{$actrel}{totalprs} = "$tmp[0]";}
			
}	
$dir = "/homes/rod/public_html/Regression/report/new/data/prdata";
$buffer = "<table class='table-bordered table-small' border=1 style='width:70%'><thead><tr><th colspan=7>$ARGV[0]</th></tr><tr><th>Release</th><th>Release Date</th><th># New PRs</th><th># Old PRs</th><th>Total</th><th># PRs Fixed</th><th>PRs open after the Release</th></tr></thead>";
foreach $r(sort keys %releasemap)
{
	$reldate="";
	if(exists $releasemap{$actrel}{reldate}){ $reldate = $releasemap{$r}{reldate};}
	$buffer .= "<tr><td>$releasemap{$r}{milestone}</td><td>$reldate</td><td><a href='$gnats_prefix".$releasemap{$r}{newprs}."$gnats_postfix' target='_blank'>$releasemap{$r}{new}</a></td>\n";
	$buffer .= "<td><a href='$gnats_prefix".$releasemap{$r}{oldprs}."$gnats_postfix' target='_blank'>$releasemap{$r}{old}</a></td>\n";
	$buffer .= "<td><a href='$gnats_prefix".$releasemap{$r}{totalprs}."$gnats_postfix' target='_blank'>$releasemap{$r}{total}</a></td>\n";
	$buffer .= "<td><a href='$gnats_prefix".$releasemap{$r}{fixedprs}."$gnats_postfix' target='_blank'>$releasemap{$r}{fixed}</a></td>\n";
	$buffer .= "<td><a href='$gnats_prefix".$releasemap{$r}{openprs}."$gnats_postfix' target='_blank'>$releasemap{$r}{open}</a></td>\n";
	$buffer .= "</tr>\n";
}
$buffer .= "</table>";
$tmprel = $release;
$tmprel =~ s/\./-/;
open(F,">$dir/$tmprel"."_prdata");
print F $buffer;
close(F);

		
sub getactrel
{
	$pl = shift;
	
	foreach $rel(@plrelarr)
	{
		$rel1 = $rel;
		$rel1 =~ s/\./\\./g;
		if($pl =~ /$rel1/) {return $rel;}
	}
}
sub checkDate
{
    $today = shift;
    $end = shift;
                ($year1,$month1,$date1) = split('-',$today);
                ($year3,$month3,$date3) = split('-',$end);
                my $todaydate = "$year1"."$month1"."$date1";
                my $enddate   = "$year3"."$month3"."$date3";
                my $today2    = new Date::Business(DATE => $todaydate);
                my $end2      = new Date::Business(DATE => $enddate);
                my $c1 = $end2->diff($today2);
                if($c1 >= 0) { return 1;}
                return 0;
}
