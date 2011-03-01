#!/usr/bin/perl
use strict;
use warnings;

# Use MT__HOME eventually
use lib '../../../lib';
use lib '../../../extlib';

use Module::Build; 
use YAML::Tiny;

my $extlib = YAML::Tiny->read( '../extlib.yaml' ); # This needs to be packaged differently.

# merge requires_noxs and requires_xs ued to generate extlib bundle
my $requires = {};
my $recommends = $extlib->[0]->{'recommends'};
my $build_requires = $extlib->[0]->{'build'};

# merge requires_noxs and requires_xs ued to generate extlib bundle
for my $x ($extlib->[0]->{'requires_noxs'}, $extlib->[0]->{'requires_xs'}) {
    for my $key (keys %$x) {
        $requires->{$key} = $x->{$key};
    }
}

my $build = Module::Build->new(
    build_class => 'Module::Build',
    build_requires => $build_requires, 
    # create_license => '', # handy eventually. requires Software::License
    # create_readme => '', # also handy eventually. need to coordinate 
    dist_abstract => 'Melody is an open source content management, blogging and publishing platform, derived from the popular blogging tool Movable Type.',
    dist_author => 'Open Melody Software Group <admin@openmelody.org>', 
    dist_name => 'Melody',
    dist_version_from => '../../../lib/MT.pm',
    license     => 'gpl',
    recommends  => $recommends, 
    requires    => $requires, 
);
$build->create_build_script;
