# NAME

ChartJS::Generator - generate HTML chart with Chart.js

# SYNOPSIS

    use ChartJS::Generator;

    my $c = ChartJS::Generator->new(
        'Bar', # Bar chart
        js     => '/path/to/Chart.js',
        title  => 'Bar chart sample', # HTML title
        width  => '800', # canvas width
        height => '600', # canvas height
    );

    # create each chart element
    my $apple => $c->create_element(apple => 'red'); # (name => color)

    # chart of sales of the yer
    my @label = ("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12");
    my @data  = (1, 3, 2, 9, 3, 8, 4, 2, 5, 4, 1, 7);
    for my $i (0..$#label){
        $apple->up($label[$i] => $data[$i]);
    }

    # render HTML
    print $c->render;

# DESCRIPTION

ChartJS::Generator is a simple HTML chart generator with [Chart.js](http://www.chartjs.org/).
Depend only Chart.js.(It doesn't require any Perl Module)
Maybe it runs every where.

# METHOD

#####new ( ChartJS::Generator->new($CHART_TYPE, %OPTION))

    $CHART_TYPE    Line, Bar, Radar, PolarArea, Pie, Doughnut
    %OPTION        js     path to Chart.js for '<script src="">' (default './Chart.js')
                   title  HTML title
                   width  canvas width  (default 960)
                   height canvas height (default 480)
                   Others are same as Chart.js options. Specify camel case.

#####create_element ($c->create_element($NAME => $COLOR))

    Create a new chart element.
    $NAME          Name of the chart element. Must be unique.
    $COLOR         yellow, blue, green, pink, red

#####create_element ($c->create_element($NAME => %COLOR))

    You can also spcify color as hash below.

    %COLOR         # Line Bar Radar
                   fill_color   => 'rgba(0,102,255,0.5)',
                   stroke_color => '#0033ff',
                   point_color  => '#0000ff',
                   point_stroke_color => '#fff',

                   # PolarArea Pie Doughnut
                   color => 'rgba(255,0,0,0.5)'

#####up ($elm->up($LABEL => $COUNT) Line, Bar, Radar

    $LABEL         Data point label.
    $COUNT         Incremental data count of the point. (default 1)

#####up ($elm->up($COUNT)) PolarArea, Pie, Doughnut

    $COUNT         Incremental data count of the point. (default 1)

#####down ($elm->down($LABEL => $COUNT) Line, Bar, Radar 

    $LABEL         Data point label.
    $COUNT         Decremental data count of the point. (default 1)

#####down ($elm->down($COUNT)) PolarArea, Pie, Doughnut

    $COUNT         Decremental data count of the point. (default 1)

#####render ($c->render())

    Render Chart HTML.

# LICENSE

Copyright (C) Tooru Iwasaki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself and under the MIT license as
Chart.js.

# AUTHOR

Tooru Iwasaki <rockbone.g@gmail.com>
