################################################################################
# Copyright (C) 2001-2007 by Juniper Networks, Inc.  All Rights Reserved
# $Id: DB.pm,v 1.68 2014/03/07 23:17:05 kenjim Exp $
# Kenji Morishige <kenjim@juniper.net>
################################################################################

# !!!! THIS IS A DEPRECATED MODULE !!!!
# DO NOT WRITE ANY NEW TOOLS USING THIS MODULE.  PLEASE USE DBI.pm DIRECTLY!
# This module is only being updated for connection string changes to support 
# legacy tools to work with pgbouncer proxying system.  Web apps especially 
# should not use this module!

# An old DBI connection wrapper library with static exported functions being 
# used in tools for a long time.

package SysTest::DB;
use strict;

use Exporter;
use DBI;
use Carp qw(confess);

BEGIN {
  use vars qw( $VERSION @ISA @EXPORT );
  @ISA = qw( Exporter );
  @EXPORT = qw( 
      db_connect db_disconnect db_execute db_get_all_rows db_get_one_row db_table_lock
      db_table_unlock db_simple_select db_insert db_update db_error_code db_error_str
      get_type_items quote_escape set_dsn get_dsn_string sql_do sql_insert sql_update
      sql_select sql_select_many sql_select_arrayref sql_select_hash sql_select_hashref
      sql_select_all sql_select_all_hashref sql_select_all_hashref_array sql_select_col_array
      sql_simple_select sql_count sql_with_bind_columns db_undef last_sql
      );
  $VERSION = do { my @r = (q$Revision: 1.68 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; # must be all one line, for MakeMaker

  # Available PostgreSQL Connection Ports 
  use constant PG_PORT              => 5432; # direct connection, bypassing pg_bouncer proxy server
  use constant PGB_STATEMENT_PORT   => 6543; # most simple connections should use this mode
  use constant PGB_TRANSACTION_PORT => 6544; # for connnections using BEGIN/COMMIT blocks
  use constant PGB_SESSION_PORT     => 6542; # sticky session mode
  use constant PGB_SVL_SLAVE_STATEMENT_PORT => 6553; # this is now the new read-only accounts default 
                                                     # changes made recently for TT-25508
}

# this is the default object that this module uses if the module is used  in a static function style, the default
# object is this package variable  before using it, the set_dsn function must be called again to specify the
# appropriate database to communicate with
$SysTest::DB::static = {
  DEBUG         => 0, 
  DEBUG_SQL     => 0, 
  TRACE         => 0,
  DEBUG_FILE    => '/tmp/SysTest-DB.pm.log',
  CONNECT_RETRY => 3, 
  QUERY_RETRY   => 3
};

# bless the package variable into object with the same name as our package
bless $SysTest::DB::static, 'SysTest::DB';

# no longer enabling the setting of default dsn at compile time
#set_dsn($ENV{DSN_DEFAULT} || "pg_live"); 

sub new {
  # gets package name, or mix-in object reference
  my $self = shift;
  my $class = ref($self) || $self;
  unless (ref($self)) {
    $self = {};
    # inherit the static's default values
    %$self = %$SysTest::DB::static;
  }
  bless $self, $class;
  # for now make the constructor use the same arguments as the set_dsn function, may change this soon since
  # none of the code uses this type of constructor other than Teck's code that uses DBO.pm which is similar
  $self->set_dsn(@_); 
  return $self;
}

###############################################################################
# Database Connectivity
###############################################################################
sub set_dsn {
  my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
  my ($id,$params) = @_;

  $self->{_dsn_attr} = { 
    LongReadLen => 0, PrintError  => 0, InactiveDestroy => 1, 
    pg_server_prepare => 0 # this turns off server-side prepare in DBD::Pg
  };

  #if (defined $params->{name} && ref($params->{name}) eq 'HASH') { 
    #$params->{attr} = $params->{name}; $params->{name}= ''; 
  #}

  $self->{_dsn_id}   = $id;
  $self->{_dsn_type} = (defined $params->{type}) ? $params->{type} : 'Pg';
  $self->{_dsn_user} = (defined $params->{user}) ? $params->{user} : 'readonly';
  $self->{_dsn_pass} = (defined $params->{pass}) ? $params->{pass} : 'readonly';
  $self->{_dsn_pass} = $params->{user} if (defined $params->{user} && ! defined $params->{pass});
  $self->{_dsn_port} = (defined $params->{port}) ? $params->{port} : SysTest::DB::PGB_STATEMENT_PORT;
  $self->{_dsn_xtra} = (defined $params->{xtra}) ? $params->{xtra} : '';

  if (defined $params->{attr} && ref($params->{attr}) eq 'HASH') {
    %{$self->{_dsn_attr}} = (%{$self->{_dsn_attr}},%{$params->{attr}}) 
  }
  
  # named connection profiles
  if ($id eq 'live' || $id eq 'pg_live') {
    # the defaults below will be changed after cutover in 2011-Q2!
    $self->{_dsn_name} = 'systest_live';
# psen: Commenting out the line below as user 'stdb_legacy_default' is disabled
#    $self->{_dsn_user} = 'stdb_legacy_default';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
# psen: Commenting out the line below as user 'stdb_legacy_default' is disabled
#    $self->{_dsn_port} = SysTest::DB::PG_PORT; # direct for now
  }
  elsif ($id eq 'cuty' || $id eq 'pg_cuty') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_port} = '6545'; # custom port for cuty
    $self->{_dsn_user} = 'cuty';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'params' || $id eq 'pg_params') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'params';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
    $self->{_dsn_port} = SysTest::DB::PGB_TRANSACTION_PORT;
  }
  elsif ($id eq 'bngparams' || $id eq 'pg_bngparams') {
    $self->{_dsn_id}   = "pg_bngparams";
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'params';
    $self->{_dsn_pass} = 'params';
    $self->{_dsn_port} = '6544';
    $self->{_dsn_host} = 'bng-params-db.juniper.net';
  }
  elsif ($id eq 'pg_tt_test_90') {
    $self->{_dsn_name} = 'systest_live_90';
    $self->{_dsn_user} = 'regressd';
    $self->{_dsn_pass} = 'z2Td6GcH';
    $self->{_dsn_host} = 'ttpgdb-test.juniper.net';
    $self->{_dsn_port} = '6546';
  }
  elsif ($id eq 'pg_tt_lrm_devel') {
    $self->{_dsn_name} = 'lrm_test';
    $self->{_dsn_user} = 'lrm_read';
    $self->{_dsn_host} = 'crx.englab.juniper.net';
    $self->{_dsn_port} = '5431';
  }
  elsif ($id eq 'res' || $id eq 'pg_res') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'res';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
    $self->{_dsn_port} = SysTest::DB::PGB_TRANSACTION_PORT;
  }
  elsif ($id eq 'jbatch' || $id eq 'pg_jbatch') {
    $self->{_dsn_name} = 'systest_live';
    #$self->{_dsn_port} = SysTest::DB::PG_PORT; # direct for now
    $self->{_dsn_user} = 'jbatch';
    $self->{_dsn_pass} = 'mg2u2R07';
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'clean_config' || $id eq 'pg_clean_config') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'res';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'regressd' || $id eq 'pg_regressd') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'regressd'; 
    $self->{_dsn_port} = '6546';
    $self->{_dsn_pass} = 'z2Td6GcH';
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'regressd_gui' || $id eq 'pg_regressd_gui') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'regressd_gui';
    #$self->{_dsn_port} = '5432';
    $self->{_dsn_port} = '6546';
    $self->{_dsn_pass} = 'regressd_gui';
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'jtms_legacy' || $id eq 'pg_jtms_legacy') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'jtms_legacy'; 
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'rsp_mason' || $id eq 'pg_rsp_mason') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'rsp_mason'; 
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'ext_ft_dr_gui_rw') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'ext_ft_dr_gui_rw'; 
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'ext_ft_etrans_gui_rw') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'ext_ft_etrans_gui_rw';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'cbr_cli' || $id eq 'pg_cbr_cli') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'cbr_cli'; 
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
  }
  elsif ($id eq 'regressd_devel' || $id eq 'pg_regressd_devel') {
    $self->{_dsn_name} = 'regressd_devel';
    $self->{_dsn_user} = 'regressd'; 
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
  }
  elsif ($id eq 'bng_dt_devel' || $id eq 'pg_bng_dt_devel') {
    $self->{_dsn_name} = 'bng_dt_devel';
    $self->{_dsn_host} = 'bng-log01.jnpr.net';
  }
  elsif ($id eq 'pg_devel' || $id eq 'devel') {
    $self->{_dsn_name} = 'systest_devel';
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
  }
  elsif ($id eq 'pg_devel2' || $id eq 'devel2') {
    $self->{_dsn_name} = 'systest_devel2';
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
  }
  elsif ($id eq 'pg_devel3' || $id eq 'devel3') {
    $self->{_dsn_name} = 'systest_devel3';
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
  }
  elsif ($id eq 'ti_live' || $id eq 'pg_ti_live') {
    $self->{_dsn_name} = 'systest_live';
    $self->{_dsn_user} = 'ti_default';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'ttpgdb.juniper.net';
    $self->{_dsn_port} = SysTest::DB::PGB_TRANSACTION_PORT;
  }
  elsif ($id eq 'ti_devel' || $id eq 'pg_ti_devel') {
    $self->{_dsn_name} = 'ti_devel';
    $self->{_dsn_user} = 'ti_devel';
    $self->{_dsn_pass} = $self->{_dsn_user};
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
  }
  elsif ($id eq 'pg_devel_yesterday' || $id eq 'devel_yesterday') {
    $self->{_dsn_port} = '5432';
    $self->{_dsn_name} = 'yesterday';
    $self->{_dsn_host} = 'crx.englab.juniper.net';
  }
  elsif ($id eq 'pg_trolls2' || $id eq 'trolls2') {
    $self->{_dsn_port} = '5432';
    $self->{_dsn_name} = 'systest_trolls2';
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
  }
  elsif ($id eq 'pg_dt_devel' || $id eq 'dt_devel') {
    $self->{_dsn_name} = 'dt_devel';
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
  }
  elsif ($id eq 'pg_dt_devel_6544' || $id eq 'dt_devel_6544') {
    $self->{_dsn_name} = 'dt_devel';
    $self->{_dsn_host} = 'sniper.englab.juniper.net';
    $self->{_dsn_port} = SysTest::DB::PGB_TRANSACTION_PORT;
  } else {

    # setup custom login role id/username/password
    $self->{_dsn_user} = $id; $self->{_dsn_pass} = $id;
    my %environments = (
        production => {
          host => 'ttpgdb.juniper.net',
          name => 'systest_live' },
        production_readonly => { 
          host => 'ttpgdb.juniper.net',
          name => 'systest_live_readonly' },
        development => { 
          host => 'sniper.englab.juniper.net',
          name => 'systest_devel' },
        staging => {
          host => 'tesla.englab.juniper.net',
          name => 'yesterday' });

    
    if (defined $params->{environment} && defined $environments{$params->{environment}}) {
      $self->{_dsn_host} = $environments{$params->{environment}}{host};
      $self->{_dsn_name} = $environments{$params->{environment}}{name};
    } elsif (defined $params->{environment}) {
      confess "undefined preset database environment requested, currently available: " .  join ",",keys %environments;
    } else {
      # go to production by default
      $self->{_dsn_host} = $environments{production}{host};
      $self->{_dsn_name} = $environments{production}{name};
    }
    
    # added 2013-08-30 after readonly disabled and systest_live_readonly made available
    # updated 2014-03-06 (TT-2550)
    if ($self->{_dsn_user} =~ /_ro$/ || 
        $self->{_dsn_user} eq 'readonly' ||
        $self->{_dsn_user} eq 'ext_cbu_dash_gui' ) {
      $self->{_dsn_port} = SysTest::DB::PGB_SVL_SLAVE_STATEMENT_PORT;
      $self->{_dsn_name} .= '_readonly';
    }

    # over-write host/name if user accidently provides both
    $self->{_dsn_host} = $params->{host} if (defined $params->{host});
    $self->{_dsn_host} = $params->{hostname} if (defined $params->{hostname});
    $self->{_dsn_name} = $params->{name} if (defined $params->{name});
    $self->{_dsn_name} = $params->{database} if (defined $params->{database});
    $self->{_dsn_user} = $params->{user} if (defined $params->{user});
    $self->{_dsn_user} = $params->{username} if (defined $params->{username});
    $self->{_dsn_user} = $params->{role} if (defined $params->{role});
    $self->{_dsn_pass} = $params->{pass} if (defined $params->{pass});
    $self->{_dsn_pass} = $params->{password} if (defined $params->{password});
  }

  # Postgres and MySQL have different DSN style that get passed to DBI
  if ($self->{_dsn_type} eq 'Pg') {
    $self->{_dsn}  = "dbi:Pg:dbname=$self->{_dsn_name}" .
      ";host="     . $self->{_dsn_host} .
      ";port="     . $self->{_dsn_port};
  } else {
    # MySQL
    $self->{_dsn}  = "dbi:" . $self->{_dsn_type} .
      ":database=" . $self->{_dsn_name} .  ";host=" . $self->{_dsn_host} .
      ";port=" . $self->{_dsn_port};
    $self->{_dsn} .= ";$self->{_dsn_xtra}" if $self->{_dsn_xtra};
  }
  # this is to populate the default package variable, for when methods are used as static functions
  foreach (keys %$self) {
    eval("\$SysTest::DB::$_ = \$self->{$_}");
  }
}

sub get_dsn_string {
  my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
  return "$self->{_dsn_user}\@$self->{_dsn_name} on $self->{_dsn_host}";
}

###############################################################################
# another db_connect wrapper here for legacy purposes.
# it seems that DBI now does have a handle cache mechanism.
sub db_connect {
  my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
  my ($restart) = @_;
  # this is reset here because every function # calls this function prior to
  # running a query.  the DBI error code can usually be # accessed directly,
  # but sometimes it is  cleared not accessible when a embedded calling
  # function is used.
  $self->{ERROR} = 0;
  # get a new handle.
  $self->db_disconnect() if $restart;
  my $retry_count = 0;
TRY: {
       local @_;
       my $old_alarm = alarm 30;
       eval {
         local $SIG{'ALRM'} = sub { die "connection timed out" };
         if (defined $self->{_dbh} && ref $self->{_dbh}) {
           $self->{_dbh} = DBI->connect_cached($self->{_dsn}, $self->{_dsn_user}, 
               $self->{_dsn_pass}, $self->{_dsn_attr});
         } else { # DBI's internal cache breaks if we damn _dbh
           $self->{_dbh} = DBI->connect($self->{_dsn}, $self->{_dsn_user}, $self->{_dsn_pass}, $self->{_dsn_attr});
         }
       };
       alarm $old_alarm;
       if ($@ || !defined $self->{_dbh}) {
         $retry_count++;
         if ($retry_count <= $self->{CONNECT_RETRY}) {
           $self->debug_sql("[pid:$$] db_connect: retrying to connect to database $self->{_dsn} $@\n");
           print STDERR "[pid:$$] db_connect: retrying to connect to database $self->{_dsn} $@\n";
           next TRY;
         }
         die "database would not let us connect $DBI::errstr";
       }
     }
     # this is like this for backwards compatibility
     return $self->{_dbh};
}

# this is a wrapper to try to dissassociate the process from any database connections  without calling a db_disconnect. # This might be usefull in forked processes, when  $dbh->{InactiveDestroy} isn't doing what you think it aught to and
# when db_connect doesn't give you a new connection since we are using connect_cached. 
sub db_undef {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    undef $self->{_dbh};
    delete $self->{_dbh};
}

sub db_disconnect {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    $self->debug_sql("db_disconnect: $self->{_dbh}");
    # added to remove warning when people are just using this legacy module
    delete $SysTest::DBH->{"$self->{_dsn_id}"} if defined $SysTest::DBH->{"$self->{_dsn_id}"};
    $self->{_dbh}->disconnect();
    undef $self->{_dbh};
}

# many db_xxxx functions are kinda old and are still around for compatibility's sake
################################################################################
sub db_execute {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $self->sql_do(@_);
}

################################################################################
sub db_table_lock {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($table_spec) = @_;
    return $self->db_execute("LOCK TABLES $table_spec");
}

################################################################################
sub db_table_unlock {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $self->db_execute("UNLOCK TABLES");
}

################################################################################
sub db_get_one_row {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $self->sql_select_hash(@_);
}

################################################################################
sub db_get_all_rows {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    # return sql_select_all_hashref_array(@_);
    # trying to see if old one works better:
    # problem about this method and modules is it doesn't allow for catching
    # failures during mid-query, need to specify RaiseError
    
    my ($sql) = @_;
    $self->db_connect(); $self->dump_sql("db_get_all_rows:\n$sql");
    my $sth = $self->{_dbh}->prepare($sql); # maybe this will help performance
    my $rv = $sth->execute;
    $self->debug_dbh("db_get_all_rows",$sql);
    my @allrows;
    while ($rv > 0) {
        my %data = %{$sth->fetchrow_hashref};
        push @allrows, \%data;
        $rv--;
    }
    #while ($sth->fetchrow_hashref) {
        #push @allrows, $_;
    #}
    warn($sth->errstr) if $sth->err;
    $sth->finish; # according to DBI documentation, finish command isn't necessary
    return wantarray ? @allrows : \@allrows;
}

################################################################################
sub db_simple_select {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $self->sql_simple_select(@_);
}

################################################################################
sub sql_do {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_; my $tries = 0;
    $self->dump_sql("sql_do:\n$sql");
    TRY: {
        $self->db_connect();
        $tries++;
        my $rc = $self->{_dbh}->do($sql);
        next TRY if (!$rc && ($self->db_error_code() == 2013) && 
                    ($tries <= $self->{QUERY_RETRY}));
        $self->debug_dbh("sql_do",$sql);
        return $rc;
    }
}

################################################################################
sub sql_simple_select {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($table,$columnsAR,$whereHR,$order) = @_;
    $self->{_dbh} || $self->db_connect();
    my $columns = "  ";
    if (ref($columnsAR)) {
        $columns .= join ",\n  ", @$columnsAR;
    } else {
        $columns .= "$columnsAR";
    }
    my $where = "";
    $order = ($order) ? " ORDER BY $order" : "";
    if (ref($whereHR)) {
      foreach (keys %$whereHR) {
          $where .= "AND " if $where;
          if (/^-/) {
	     s/^-//;
             $where .= "$_=$whereHR->{-$_}\n";
          } else {
             $where .= "$_=" . $self->{_dbh}->quote($whereHR->{$_}) . "\n";
	  }
      }
    } elsif ($whereHR) {
      $where = $whereHR;
    }
    $where  = " WHERE $where" if $where;
    my $sql = "SELECT $columns FROM $table$where$order";
    return $self->sql_select_all_hashref_array($sql);
}

################################################################################
sub sql_select_many {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    $self->db_connect(); $self->dump_sql("sql_select_many:\n$sql");
    my $sth = $self->{_dbh}->prepare_cached($sql);
    if ($sth->execute) {
        return $sth;
    } else {
        $self->debug_dbh("sql_select_many",$sql);
        $self->{ERROR} = $DBI::err;
        $sth->finish;
        return undef;
    }
}

################################################################################
sub sql_select {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    $self->db_connect(); $self->dump_sql("sql_select:\n$sql");
    my @r = ();
    my $sth = $self->{_dbh}->prepare_cached($sql);
    if ($sth->execute) {
        @r = $sth->fetchrow;
        #$sth->finish;
        return @r;
    } else {
        $self->debug_dbh("sql_select",$sql);
        $sth->finish;
	return;
    }
}

################################################################################
sub sql_select_arrayref {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    $self->db_connect(); $self->dump_sql("sql_select_arrayref:\n$sql");
    my $sth = $self->{_dbh}->prepare_cached($sql);
    my $r = [];
    if ($sth->execute) {
        $r = $sth->fetchrow_arrayref;
    } else {
        $self->debug_dbh("sql_select_arrayref",$sql);
    }
    #$sth->finish;
    return $r;
}

################################################################################
sub sql_select_hash {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my $hash = $self->sql_select_hashref(@_);
    return wantarray ? (map { $_ => $hash->{$_} } keys %$hash) : $hash;
}

################################################################################
sub sql_select_hashref {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    $self->db_connect(); $self->dump_sql("sql_select_hashref:\n$sql");
    my $sth = $self->{_dbh}->prepare_cached($sql);
    my $hr  = {};
    if ($sth->execute) {
        $hr = $sth->fetchrow_hashref;
    } else {
        $self->debug_dbh("sql_select_hashref",$sql);
    }
    $sth->finish;
    return $hr;
}

################################################################################
sub sql_select_col_array {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    $self->db_connect(); $self->dump_sql("sql_select_col_array:\n$sql");
    my $sth = $self->{_dbh}->prepare_cached($sql);
    my $a = $self->{_dbh}->selectcol_arrayref($sth);
    unless (defined($a)) {
        $self->debug_dbh("sql_select_col_array",$sql);
	return;
    }
    return wantarray ? @$a : $a;
}

################################################################################
sub sql_select_all {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    $self->db_connect(); $self->dump_sql("sql_select_all:\n$sql");
    my $h = $self->{_dbh}->selectall_arrayref($sql);
    unless ($h) {
        $self->debug_dbh("sql_select_all",$sql);
	return undef;
    }
    return $h;
}

################################################################################
sub sql_select_all_hashref {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($key_col,$sql) = @_;
    my $tries = 0;
    TRY: {
        $tries++;
        my $sth = $self->sql_select_many($sql);
        my $rv  = {};
        return $rv unless $sth;
        while (my $row = $sth->fetchrow_hashref) {
            $rv->{$row->{$key_col}} = $row;
        }
        if (($self->db_error_code() == 2013) && ($tries <= $self->{QUERY_RETRY})) {
            # if the connection was lost, try it again.
            $sth->finish;  
            next TRY;
        }
        $sth->finish;
        return $rv;
    }
}

################################################################################
sub sql_select_all_hashref_array {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    my $tries = 0;
TRY: {
         $tries++;
         my $sth = $self->sql_select_many($sql);
         my @rv;
         unless ($sth) {
             return wantarray ? @rv : \@rv;
         }
         while (my $row = $sth->fetchrow_hashref) {
             push @rv, $row;
         }
         # took this out for now... for pgsql
         #if (($self->db_error_code() == 2013) && ($tries <= $self->{QUERY_RETRY})) {
             # if the connection was lost, try it again.
             $sth->finish;  
             #next TRY;
             #}
             #$sth->finish;
             return wantarray ? @rv : \@rv;
     }
}


################################################################################
# old name for compatibility
sub db_insert {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $self->sql_insert(@_);
}

# argument usage:
# $table - name of the database table you are inserting into
# $data  - a hash with keys named the column name, if you don't want to run the
#          $dbh->quote() function on the data, precede the column key with a -
# $delay - this was a MySQL specific feature to help performance, rarely used
# $getid - originally when this library was for MySQL, when this value was true
#          it would just return the new primary key generated from the 
#          auto_increment column. The same behavior is retained if the database
#          handle is MySQL. If it is Postgres, if the $getid value contains text
#          it will be assumed that it is the name of the sequence in which we
#          chould call the currval function on.

sub sql_insert {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my($table, $data, $delay, $getid) = @_;
    my($names, $values);
    $self->db_connect();
    foreach (keys %$data) {
        if (/^-/) {
            $values .= "\n  $data->{$_},";
            s/^-//;
        } else {
            $values .= "\n  " . $self->{_dbh}->quote($data->{$_}) . ',';
        }
        $names .= "$_,";
    }
    chop($names); chop($values);
    my $p   = ''; $p = ' DELAYED' if ($delay && $self->{_dsn_type} eq 'mysql');
    my $sql = "INSERT$p INTO $table ($names) VALUES ($values)\n";

    # the default method to get last_insert_id has been changed to deal with how
    # pgbouncer multiplexes statements coming in from different clients.  
    # In the past, we would construct the default sequence name and extract currval from it manually
    # after the insert.  We will still provide that option if user provides sequence name manually
    # to the function, though this should only be used against non-pgbouncer statement mode connections.
    my $ret; my $sth;
    if ($getid && ($getid =~ /^\d+$/ || $getid !~ /seq/)) {
      $sth = $self->{_dbh}->table_info('','',$table,'TABLE');
      my $table_info = $sth->fetchrow_hashref;
      $sth->finish;
      my $schema = $table_info->{TABLE_SCHEM};
      my ($oid) = $self->{_dbh}->selectrow_array("SELECT c.oid FROM pg_catalog.pg_class c 
        JOIN pg_catalog.pg_namespace n ON (n.oid = c.relnamespace)
        WHERE relname = '$table' AND n.nspname = '$schema'");
      $oid ||= -1; # in case above query fails
      my $col = $self->{_dbh}->selectrow_hashref("SELECT a.attname, i.indisprimary, substring(d.adsrc for 128) AS def
          FROM pg_catalog.pg_index i, pg_catalog.pg_attribute a, pg_catalog.pg_attrdef d
          WHERE i.indrelid = $oid AND d.adrelid=a.attrelid AND d.adnum=a.attnum
          AND a.attrelid = $oid AND i.indisunique IS TRUE
          AND a.atthasdef IS TRUE AND i.indkey[0]=a.attnum
          AND d.adsrc ~ '^nextval'");
      
      if ($col->{attname} && $col->{def} =~ /nextval/) {
        $sql .= "RETURNING $col->{attname}\n";
        $sth = $self->{_dbh}->prepare($sql);
        $ret = $sth->execute;
        if ($ret && $ret ne '0E0') {
          ($ret) = $sth->fetchrow_array;
        } 
      }
      
    } elsif ($getid && $getid =~ /_seq$/) {
      # if sequence name is specified, use currval extraction method
      $sth = $self->{_dbh}->prepare($sql);
      $ret = $sth->execute;
      if ($ret && $ret ne '0E0') {
        ($ret) = $self->{_dbh}->selectrow_array("SELECT currval('$getid') as currval");
      }
    } else {
      # no get last insert id
      $sth = $self->{_dbh}->prepare($sql);
      $ret = $sth->execute;
    }

    $self->dump_sql("sql_insert:\n$sql");
    if ($self->{_dbh}->err) {
        $self->debug_dbh("sql_insert",$sql);
        $sth->finish;
        return $ret;
    }
    
    if ($ret eq '0E0') {
      $ret = 0;
    }

    return $ret;
}

###############################################################################
sub db_update {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $self->sql_update(@_);
}

###############################################################################
sub sql_update {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my($table, $dataHR, $whereHR, $lp) = @_;
    $self->db_connect();
    $lp       = ($lp) ? 'LOW_PRIORITY ' : "";
    my $sql   = "UPDATE $lp$table SET";
    my $where = "";
    foreach (keys %$dataHR) {
        if (/^-/) {
            s/^-//;
            $sql .= "\n $_ = $dataHR->{-$_},";
        } else {
            $sql .= "\n $_ = " . $self->{_dbh}->quote($dataHR->{$_}) . ',';
        }
    }
    chop $sql;
    if (ref($whereHR)) {
      foreach (keys %$whereHR) {
          $where .= "AND " if $where;
          if (/^-/) {
	     s/^-//;
             $where .= "$_=$whereHR->{-$_}\n";
          } else {
             $where .= "$_=" . $self->{_dbh}->quote($whereHR->{$_}) . "\n";
	  }
      }
    } elsif ($whereHR) {
      $where = $whereHR;
    }
    $sql .= "\nWHERE $where";
    my $rv = $self->sql_do($sql);
    return $rv;
}

###############################################################################
sub sql_count {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($table,$where) = @_;
    my $sql = "SELECT count(*) AS count FROM $table";
    $sql   .= " WHERE $where" if $where;
    $self->db_connect(); $self->dump_sql("sql_count:\n$sql");
    my $rc = $self->{_dbh}->selectrow_array($sql);
    return $rc;
}

#this method allows to execute sql statement with support for bind columns, the method accepts named
# parameter style, and will not work with oracle as oracle treates bind column differently.
# added by Bushan
###############################################################################
sub sql_with_bind_columns {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my (%param_hash) = @_;
    my ($sth,$i,$data_records_ref,$col_list_ref);
    my $TRUE = 1; my $FALSE = 0;
    $self->db_connect();
    $sth = $self->{_dbh}->prepare($param_hash{query});
    if ($param_hash{bind_cols}) {
        for ( $i = 0; $i <= $#{$param_hash{bind_cols}}; $i++) {
            $sth->bind_param($i+1, $param_hash{bind_cols}->[$i]) ||
              return $FALSE, "Cant bind parameter $param_hash{bind_cols}->[$i]   $DBI::errstr ";
        }
    }
    # Now Execute Statement
    $sth->execute() || return $FALSE, "Cant exec stmt $DBI::errstr";
    # Now if the statement was sql select, extract data
    if ($param_hash{type} =~ /select/ ){
        ($data_records_ref) = $sth->fetchall_arrayref() ||
          return $FALSE, "Cant  get ref to all recrds ::: $DBI::errstr ";
        ($col_list_ref) =  $sth->{NAME};
        $sth->finish ||
          return $FALSE , "cant close Stmnt ::: $DBI::errstr ";
        $sth->finish;
        return $TRUE, $data_records_ref, $col_list_ref;
    }
    $sth->finish;
    return $TRUE;
}

# this assumes that the schema has Kenji's type/type_item
# tables.  The input is the type name. It returns a 
# db_get_all_rows type array of all the type_items
# if the input is a integer it will compare agains the type_id
# otherwise it will use the type_name
###############################################################################
sub get_type_items {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($type_id) = @_;
    $type_id = quote_escape($type_id);
    my $where_option;
    if ($type_id =~ /\D/) {
       $where_option .= "t.type_name = $type_id"
    } else {
       $where_option .= "t.type_id = $type_id"
    }
    my $sql=<<ENDL;
    SELECT
        t.type_id          as type_id,
	t.type_name        as type_name,
	ti.type_item_name  as type_item_name,
	ti.type_item_code  as type_item_code,
	ti.type_item_value as type_item_value,
	ti.type_item_order as type_item_order,
	ti.description     as type_item_description,
	ti.create_date	   as type_item_create_date,
        ti.update_date     as type_item_update_date
    FROM
        type t, type_item ti
    WHERE
	$where_option
    AND t.type_id = ti.type_id
ENDL
    return $self->db_get_all_rows($sql);
}

###############################################################################
sub db_error_code {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $self->{ERROR} if $self->{ERROR};
    return $DBI::err if $DBI::err;
    return;
}

###############################################################################
sub db_error_str {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    return $DBI::errstr if $DBI::errstr;
    return;
}

###############################################################################
sub quote_escape {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    $self->db_connect();
    return $self->{_dbh}->quote(shift);
}

###############################################################################
sub dump_sql {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($sql) = @_;
    $self->{LAST_SQL} = $sql;
    #$self->{DEBUG_SQL} && $sql && debugger("$sql\n",$self->{DEBUG_FILE});
}

sub last_sql {
  my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
  return $self->{LAST_SQL};
}

###############################################################################
sub debug_dbh {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($header,$sql) = @_;
    unless (defined $self->{_dbh}) {
        #debugger("dbh was undefined",$self->{DEBUG_FILE}) if ($self->{DEBUG});
        return ;
    }
    if (($self->{_dbh}->err) && ($self->{DEBUG} || $self->{TRACE})) {
        my $dstr = "";
        my $now  = localtime;
        $dstr   .= "[ERROR: $now]\n";
        $dstr   .= "   sub: $header\n" if $header;
        $dstr   .= "errnum: " . $self->{_dbh}->err    . "\n" . 
          "errstr: " . $self->{_dbh}->errstr . "\n";
        $dstr   .= "   sql:\n$sql\n" if $sql;
        #debugger("$dstr",$self->{DEBUG_FILE}) if ($self->{DEBUG});
        print $dstr if ($self->{TRACE});
    }
}

###############################################################################
sub debug_sql {
    my $self = (ref($_[0]) =~ /SysTest::DB/) ? shift @_ : $SysTest::DB::static;
    my ($debug) = @_;
    #$self->{DEBUG} && $debug && debugger("$debug\n",$self->{DEBUG_FILE});
    $self->{TRACE} && $debug && print "$debug\n";
}

1;
