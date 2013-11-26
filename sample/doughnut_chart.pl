#!/usr/bin/env perl
use strict;
use warnings;
use lib '../lib';
use ChartJS::Generator;

### Sample data
my @os = qw/iOS Android WindowsPhone FireFox Tizen/;
my %data  = (
    iOS           => [39, 'blue'],
    Android       => [46, 'pink'],
    WindowsPhone  => [5, 'yellow'],
    FireFox       => [2, 'green'],
    Tizen         => [1, {color => '#E0E4CC'}],
);
my $c = ChartJS::Generator->new(
    'Doughnut',
    js     => 'http://cdn.rockbone.info/js/misc/Chart.js',
    title  => "Mobile OS Share",
    width  => 1200,
    height => 800,
);
for my $name (@os){
    my $elm = $c->create_element($name => $data{$name}[1]);
    $elm->up($data{$name}[0]);
}
print $c->render;
