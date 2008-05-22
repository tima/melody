#!/usr/bin/perl

# Movable Type (r) Open Source (C) 2001-2008 Six Apart, Ltd.
# This program is distributed under the terms of the
# GNU General Public License, version 2.
#
# $Id$

use strict;
use warnings;
use Data::Dumper;
use English qw( -no_watch_vars );

$OUTPUT_AUTOFLUSH = 1;

# Run this script as a symlink, in the form of 99-driver.t, ie:
# ln -s driver-tests.pl 99-driver.t

BEGIN {
    # Set config to driver-test.cfg when run as /path/to/99-driver.t
    $ENV{MT_CONFIG} = "$1-test.cfg"
        if __FILE__ =~ m{ ([^\\/-]+) \.t \z }xms;
}

use Test::More;
use lib 't/lib';
use MT::Test qw( :testdb );

BEGIN {
    plan skip_all => "Configuration file $ENV{MT_CONFIG} not found"
        if !-r $ENV{MT_CONFIG};
}

plan tests => 30;


package Ddltest;

use base qw( MT::Object );

__PACKAGE__->install_properties({
    column_defs => {
        id           => 'integer not null auto_increment',
        string_25    => 'string(25)',
        string_25_nn => 'string(25) not null',
        string_255   => 'string(255)',
        string_1024  => 'string(1024)',
        int_bool     => 'boolean',
        int_bool_nn  => 'boolean not null',
        int_small    => 'smallint',
        int_small_nn => 'smallint not null',
        int_med      => 'integer',
        int_med_nn   => 'integer not null',
        int_big      => 'bigint',
        int_big_nn   => 'bigint not null',
        float        => 'float',
        float_nn     => 'float not null',
        text         => 'text',
        text_nn      => 'text not null',
        blob         => 'blob',
        blob_nn      => 'blob not null',
        datetime     => 'datetime',
        datetime_nn  => 'datetime not null',
    },
    indexes => {
        name       => 1,
        status     => 1,
        created_on => 1,
    },
    audit       => 1,
    datasource  => 'ddltest',
    primary_key => 'id',
    cacheable   => 0,
});


package main;

my $driver    = MT::Object->dbi_driver;
my $dbh       = $driver->rw_handle;
my $ddl_class = $driver->dbd->ddl_class;

# The table may exist from a previous test, so delete it if it does.
eval {
    if ($driver->table_exists('Ddltest')) {
        my $sql = $driver->dbd->ddl_class->drop_table_sql('Ddltest');
        $driver->rw_handle->do($sql);
    }
};

ok(!$driver->table_exists('Ddltest'), 'Ddltest table does not yet exist');
ok(!defined $ddl_class->column_defs('Ddltest'), 'Ddltest table has no column defs');

my $create_sql = $ddl_class->create_table_sql('Ddltest');
ok($create_sql, 'Create Table SQL for Ddltest is available');
my $res = $dbh->do($create_sql);
ok($res, 'Driver could perform Create Table SQL for Ddltest');
diag($dbh->errstr || $DBI::errstr) if !$res;

sub _def {
    my ($auto, $not_null, $type, $size) = @_;
    my $def = {
        auto => $auto,
        not_null => $not_null,
        type => $type,
    };
    $def->{size} = $size if defined $size;
    return $def;
}

my $defs = MT::Object->driver->dbd->ddl_class->column_defs('Ddltest');
ok($defs, 'Ddltest DDL settings are defined');

sub is_def {
    my ($got, $expected, $reason) = @_;

    for my $field (qw( not_null auto )) {
        if ($expected->{$field} xor $got->{$field}) {
            fail($reason);
            diag($expected->{$field}
                ? "Expected $field but didn't get it"
                : "Expected not $field but got it");
            return;
        }
    }

    if ($expected->{type} ne $got->{type}) {
        fail($reason);
        diag("Expected type ", $expected->{type}, " but got ", $got->{type});
        return;
    }

    if (defined $expected->{size} && $expected->{size} != $got->{size}) {
        fail($reason);
        diag("Expected size ", $expected->{size}, " but got ", $got->{size});
        return;
    }

    pass($reason);
}

is_def($defs->{id}, _def(1, 1, 'integer'), 'Ddltest id column def is correct');

is_def($defs->{string_25},    _def(0, 0, 'string', 25),   'Ddltest string_25 column def is correct');
is_def($defs->{string_25_nn}, _def(0, 1, 'string', 25),   'Ddltest string_25_nn column def is correct');
is_def($defs->{string_255},   _def(0, 0, 'string', 255),  'Ddltest string_255 column def is correct');
is_def($defs->{string_1024},  _def(0, 0, 'string', 1024), 'Ddltest string_1024 column def is correct');
is_def($defs->{int_bool},     _def(0, 0, 'boolean'),      'Ddltest int_bool column def is correct');
is_def($defs->{int_bool_nn},  _def(0, 1, 'boolean'),      'Ddltest int_bool_nn column def is correct');
is_def($defs->{int_small},    _def(0, 0, 'smallint'),     'Ddltest int_small column def is correct');
is_def($defs->{int_small_nn}, _def(0, 1, 'smallint'),     'Ddltest int_small_nn column def is correct');
is_def($defs->{int_med},      _def(0, 0, 'integer'),      'Ddltest int_med column def is correct');
is_def($defs->{int_med_nn},   _def(0, 1, 'integer'),      'Ddltest int_med_nn column def is correct');
is_def($defs->{int_big},      _def(0, 0, 'bigint'),       'Ddltest int_big column def is correct');
is_def($defs->{int_big_nn},   _def(0, 1, 'bigint'),       'Ddltest int_big_nn column def is correct');
is_def($defs->{float},        _def(0, 0, 'float'),        'Ddltest float column def is correct');
is_def($defs->{float_nn},     _def(0, 1, 'float'),        'Ddltest float_nn column def is correct');
is_def($defs->{text},         _def(0, 0, 'text'),         'Ddltest text column def is correct');
is_def($defs->{text_nn},      _def(0, 1, 'text'),         'Ddltest text_nn column def is correct');
is_def($defs->{blob},         _def(0, 0, 'blob'),         'Ddltest blob column def is correct');
is_def($defs->{blob_nn},      _def(0, 1, 'blob'),         'Ddltest blob_nn column def is correct');
is_def($defs->{datetime},     _def(0, 0, 'datetime'),     'Ddltest datetime column def is correct');
is_def($defs->{datetime_nn},  _def(0, 1, 'datetime'),     'Ddltest datetime_nn column def is correct');

    # audit fields
is_def($defs->{created_on},  _def(0, 0, 'datetime'), 'Ddltest created_on column def is correct');
is_def($defs->{created_by},  _def(0, 0, 'integer'),  'Ddltest created_by column def is correct');
is_def($defs->{modified_on}, _def(0, 0, 'datetime'), 'Ddltest modified_on column def is correct');
is_def($defs->{modified_by}, _def(0, 0, 'integer'),  'Ddltest modified_by column def is correct');

1;
