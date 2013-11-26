#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use ChartJS::Generator;

### Sample data
my @country = qw/Japan USA China Australia Greg/;
my %data  = (
    Japan  => [20, 'blue'],
    USA    => [20, 'red'],
    China  => [20, 'yellow'],
    Australia => [20, 'pink'],
    Greg   => [20, {color => '#E0E4CC'}],
);
my $c = ChartJS::Generator->new(
    'Pie',
    js     => 'http://cdn.rockbone.info/js/misc/Chart.js',
    title  => "Countries",
    width  => 1200,
    height => 800,
);
for my $name (@country){
    my $elm = $c->create_element($name => $data{$name}[1]);
    $elm->up($data{$name}[0]);
}
print $c->render;
