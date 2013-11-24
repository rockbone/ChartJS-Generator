use strict;
use Test::More;

use_ok $_ for qw(
    ChartJS::Generator
);
is($ChartJS::Generator::VERSION, $ChartJS::Generator::Element::VERSION);

done_testing;

