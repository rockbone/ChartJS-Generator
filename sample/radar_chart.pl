#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use ChartJS::Generator;

### Sample data
my @people  = qw/tom tim bob/;
my @category = qw/physical mathematical latent creative productive supernatural/;
my %ability  = (
    tom  => [ 40, 30, 60, 90, 70, 90 ],
    tim  => [ 80, 20, 40, 50, 80, 10 ],
    bob  => [ 60, 90, 70, 80, 20, 40 ],
);
my %color = (
    tom      => 'yellow',
    tim      => 'green',
    bob      => 'pink',
);
my $c = ChartJS::Generator->new(
    'Radar',
    js     => 'http://cdn.rockbone.info/js/misc/Chart.js',
    title  => "Corporation Contract 2013",
    width  => 1200,
    height => 800,
    scaleLineColor => "rgba(1,0,0,.5)"
);
for my $p (@people){
    my $elm = $c->create_element($p => $color{$p});
    for my $i (0..$#category){
        $elm->up($category[$i], $ability{$p}->[$i]);
    }
}
print $c->render;
