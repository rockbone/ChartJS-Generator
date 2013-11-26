use strict;
use Test::More;
use Data::Dumper;
use ChartJS::Generator;

my @test_json = qw/
    {hello:"world"}
    {hey:"dj",play_list:["rock","jazz","urban_soul"]}
    {chart:[1,23,12,11,21]}
    ["like","rolling_stone",1,2,3,4,5]
    [{hello:1},{hi:2},{bye:3}]
    {hello:[[1,2,3],[1,2,3],[1,2,3],[1,2,3],["1","2","3"]]}
    {hi:[1,"2",{"hello":["3",{ok:[123,"123"]},{hello:"OK"}]}]}
    ["he\"llo",'h\'i',"o\\\\k"]
/;
my @test_pl;
for (0..$#test_json){
    (my $hash_ref = $test_json[$_]) =~ s/:/=>/g;
    $test_pl[$_] = eval "$hash_ref";
    ok(&ChartJS::Generator::jsonize($test_pl[$_]), $test_json[$_]);
}
SKIP:{
    skip "JSON.pm is not installed", 1 if !eval "require JSON;";
    my %test_pl = (
        1   => {
            Hello => "World!",
            OK    => ["1","2","3","4"],
            Test  => {name => "toru", data => [1, 2, 3, 4, "3"]}
        },
        2   => ["1", "2", "3", "4"],
        3   => {hello => "\"ok\\\"\"", yes => '\'No'},
        4   => ["\"\\OK", 1, '\'hello']
    );
    for my $key (keys %test_pl){
        ok(JSON::encode_json($test_pl{$key}), &ChartJS::Generator::jsonize($test_pl{$key}));
    }
}
done_testing;

