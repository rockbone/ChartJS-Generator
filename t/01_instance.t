use strict;
use Test::More;
use ChartJS::Generator;

my @type = qw/Line Bar Radar PolarArea Pie Doughnut/;
my %prop = (
    js      => 'js/Chart.js',
    title   => 'Test',
    width   => 1000,
    height  => 1000,
    options => {Dummy => 'dummy'}
);
my %elm_color = (
    t1    => 'yellow',
    t2    => 'pink',
    t3    => 'blue',
    t4    => 'green',
    t5    => 'red',
);

for my $type (@type){
    my $c = ChartJS::Generator->new($type);
    isa_ok($c, 'ChartJS::Generator', "instance chart type [$type] isa 'ChartJS::Generator'");
    is($c->type, $type, "chart type [$type]");
    is($c->js, $ChartJS::Generator::CHART_JS, "default js path [$ChartJS::Generator::CHART_JS]");
    is($c->title, "", "chart title is empty");
    is($c->width, $ChartJS::Generator::CANVAS_WIDTH, "default canvas width[$ChartJS::Generator::CANVAS_WIDTH]");
    is($c->height, $ChartJS::Generator::CANVAS_HEIGHT, "default canvas height[$ChartJS::Generator::CANVAS_HEIGHT]");
    is(scalar %{$c->options}, 0, "default options hash is empty");
    can_ok($c, 'labels');
    can_ok($c, 'element');
    can_ok($c, 'spawn');
    can_ok($c, 'template');
    can_ok($c, 'button_as_html');
    can_ok($c, 'data_as_json');
    can_ok($c, 'options_as_json');
    can_ok($c, 'render');
    undef $c;
    $c = ChartJS::Generator->new(
        $type,
        js      => $prop{js},
        title   => $prop{title},
        width   => $prop{width},
        height  => $prop{height},
        %{$prop{options}}
    );
    isa_ok($c, 'ChartJS::Generator', "instance chart type [$type] isa 'ChartJS::Generator'");
    is($c->type, $type, "chart type [$type]");
    is($c->js, $prop{js}, "js path [$prop{js}]");
    is($c->title, $prop{title}, "chart title is $prop{title}");
    is($c->width, $prop{width}, "canvas width $prop{width}");
    is($c->height, $prop{height}, "canvas height $prop{height}");
    is($c->options->{Dummy}, $prop{options}->{Dummy}, "options hash is ok");
    for my $name (keys %elm_color){
        my $elm = $c->create_element($name => $elm_color{$name});
        isa_ok($elm, 'ChartJS::Generator::Element', "instance chart element isa 'ChartJS::Generator::Element'");
        is($elm->name, $name, "Element's name");
        is($elm->type, $type, "Element's chart type");
        SKIP: {
            skip "Chart type is [$type]", 4 if $type =~ /^PolarArea|Pie|Doughnut$/;
            is($elm->fill_color,         $ChartJS::Generator::COLOR_TABLE{$elm_color{$name}}->[0], "Element's fill_color");
            is($elm->stroke_color,       $ChartJS::Generator::COLOR_TABLE{$elm_color{$name}}->[1], "Element's stroke_color");
            is($elm->point_color,        $ChartJS::Generator::COLOR_TABLE{$elm_color{$name}}->[2], "Element's point color");
            is($elm->point_stroke_color, $ChartJS::Generator::COLOR_TABLE{$elm_color{$name}}->[3], "Element's point stroke color");
        }
        SKIP: {
            skip "Chart type is [$type]", 1 if $type =~ /^Line|Bar|Radar$/;
            is($elm->color, $ChartJS::Generator::COLOR_TABLE{$elm_color{$name}}->[0], "Element's color");
        }
        can_ok($elm, 'data');
        can_ok($elm, 'labels');
        can_ok($elm, 'fill_color');
        can_ok($elm, 'stroke_color');
        can_ok($elm, 'point_color');
        can_ok($elm, 'point_color');
        can_ok($elm, 'labels');
        can_ok($elm, 'up');
        can_ok($elm, 'down');
    }
}
done_testing;
