#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use ChartJS::Generator;

### Sample data
my @fluit = qw/apple banana kiwi/;
my @term  = qw/01 02 03 04 05 06 07 08 09 12/;
my %data  = (
    apple  => [ 40,  20,  60, 100,  60,  40,  80, 120,  30,  10, 140,  20],
    banana => [ 60,  30, 120, 100,  70,  90, 120,  40,  50,  50,  70,  90],
    kiwi   => [120,  80,  20,  10,  70, 120,  40,  40,  60, 120, 100,  80],
);
my %color = (
    apple     => 'red',
    banana    => 'yellow',
    kiwi      => 'green',
);
my $c = ChartJS::Generator->new(
    'Line',
    js     => 'http://cdn.rockbone.info/js/misc/Chart.js',
    title  => "Fluit Sales 2013",
    width  => 800,
    height => 500,
);
for my $f (@fluit){
    my $elm = $c->create_element($f => $color{$f});
    for my $i (0..$#term){
        $elm->up($term[$i], $data{$f}->[$i]);
    }
}
print $c->render;
