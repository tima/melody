#!/usr/bin/perl
# $Id$
use strict;
use warnings;

use lib 'lib';
use lib 'extlib';
use lib 't/lib';

use MT::Test;

use Cwd;
use File::Spec;
use File::Temp qw( tempfile );
use Test::More tests => 17;

use MT;
use MT::ConfigMgr;

use vars qw( $BASE );
require 't/test-common.pl';

my ( $cfg_file, $cfg, $mt );

my $db_dir = cwd() . '/t/db/';
( my ($fh), $cfg_file ) = tempfile();
print $fh <<CFG;
Database $db_dir/mt.db
ObjectDriver DBI::SQLite 
AltTemplate foo bar
AltTemplate baz quux
DeniedAssetFileExtensions DEFAULT
DeniedAssetFileExtensions doc
CFG
close $fh;

$cfg = MT->config;
isa_ok( $cfg, 'MT::ConfigMgr' );
ok( $cfg->read_config($cfg_file), "read '$cfg_file'" );

## Test standard get/set
is( $cfg->get('Database'), $db_dir . '/mt.db', "get(DataSource)=$db_dir" );
$cfg->set( 'DataSource', './db2' );
is( $cfg->get('DataSource'), './db2', 'get(DataSource)=./db2' );

## Test autoloaded methods
is( $cfg->DataSource, './db2', 'autoloaded DataSource=./db2' );
$cfg->DataSource('./db');
is( $cfg->DataSource, './db', 'autoloaded DataSource=./db2' );

## Test defaults
is( $cfg->Serializer, 'MT', 'Serializer=MT' );
is( $cfg->TimeOffset, 0,    'TimeOffset=0' );

## Test that multiple settings (AltTemplate) work.
my @paths = $cfg->AltTemplate;
is( $cfg->type('AltTemplate'), 'ARRAY', 'AltTemplate=ARRAY' );
is( @paths,                    2,       'paths=2' );
is( ( $cfg->AltTemplate )[0], 'foo bar',  'foo bar' );
is( ( $cfg->AltTemplate )[1], 'baz quux', 'baz quux' );

## Test that multiple settings (DeniedAssetFileExtensions) work plus the
## DEFAULT value for adding default elements
subtest "DeniedAssetFileExtensions ARRAY and DEFAULT value" => sub {

    plan tests => 2,

    my $default = [qw(
        ascx asis asp aspx bat cfc cfm cgi cmd com cpl dll
        exe htaccess html? inc jhtml js jsb jsp mht(ml)?
        msi php[s\d]? phtml? pif pl pwml py reg scr
        sh shtml? vbs vxd
    )];
    
    is( $cfg->type('DeniedAssetFileExtensions'), 'ARRAY',
        'DeniedAssetFileExtensions=ARRAY' );

    my $exts         = $cfg->DeniedAssetFileExtensions;
    my $default_plus = [ @$default, 'doc' ];

    is_deeply( $exts, $default_plus, 
                'DeniedAssetFileExtensions with DEFAULT' )
        || diag explain $exts;
};


## Test bug in early version of ConfigMgr where space was not
## stripped from the ends of values
is( $cfg->ObjectDriver, 'DBI::SQLite', 'ObjectDriver=SQLite' );

mkdir $db_dir;

undef $MT::ConfigMgr::cfg;
## Test that config file gets read correctly when passed to
## constructor.
$mt = MT->new( Config => $cfg_file, Directory => "." ) or die MT->errstr;
if ( !$mt ) { print "# MT constructor returned error: ", MT->errstr(); }
isa_ok( $mt,        'MT' );
isa_ok( $mt->{cfg}, 'MT::ConfigMgr' );
is( $mt->{cfg}->Database, $db_dir . '/mt.db', "DataSource=$db_dir" );

unlink $cfg_file or die "Can't unlink '$cfg_file': $!";
