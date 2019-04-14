#!/usr/bin/perl -w
use Net::Telnet;
use Data::Dumper;

my $str = execCmd("skyblue", "cli -c \"show version | no-more\"");
print Dumper($str);

sub execCmd {
   my ($dev, $cmd) = @_;
   my $s = new Net::Telnet (Timeout => 20,Dump_Log   =>"tellog");
   $s->open($dev);
   my $username = "regress";
   my $passwd = "MaRtInI";
   $s->login($username, $passwd);
   my @out = $s->cmd($cmd);
   $s->close;
   return \@out;
}
