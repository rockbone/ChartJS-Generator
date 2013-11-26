#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use ChartJS::Generator;

### Sample data
my @people = qw/toru ken hanako/;
my @term  = qw/1 2 3 4 5 6 7 8 9 10 11 12/;
my %contract_data  = (
    toru   => [ 4, 3, 4, 3, 2, 3, 3, 5, 4, 6, 4, 4 ],
    ken    => [ 1, 3, 3, 3, 2, 3, 7, 7, 2, 3, 2, 1 ],
    hanako => [ 3, 5, 3, 6, 0, 2, 1, 3, 3, 2, 2, 8],
);
my %color = (
    toru      => 'yellow',
    ken       => 'green',
    hanako    => 'red',
);
my $c = ChartJS::Generator->new(
    'Bar',
    js     => 'http://cdn.rockbone.info/js/misc/Chart.js',
    title  => "Corporation Contract 2013",
    width  => 1200,
    height => 800,
);
$c->sort_labels_as_number(1);
for my $p (@people){
    my $elm = $c->create_element($p => $color{$p});
    for my $i (0..$#term){
        $elm->up($term[$i], $contract_data{$p}->[$i]);
    }
}
print $c->render;
