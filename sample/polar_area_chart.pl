#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use ChartJS::Generator;

### Sample data
my @charge = qw/water gas electricity telephone/;
my %data  = (
    water  => 120,
    gas    => 80,
    electricity => 230,
    telephone => 430
);
my %color = (
    water     => 'blue',
    gas       => 'yellow',
    electricity => {color =>'#7D4F6D'},
    telephone  => 'green',
);
my $c = ChartJS::Generator->new(
    'PolarArea',
    js     => 'http://cdn.rockbone.info/js/misc/Chart.js',
    title  => "Public utility charge  2013",
    width  => 1200,
    height => 800,
);
for my $ch (@charge){
    my $elm = $c->create_element($ch => $color{$ch});
    $elm->up($data{$ch});
}
print $c->render;
