package ChartJS::Generator;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

our $CHART_JS      = './Chart.js'; # default <script src=''>
our $CANVAS_WIDTH  = 960;          # default canvas width
our $CANVAS_HEIGHT = 480;          # default canvas height
our @CHART_TYPE    = qw/Line Bar Radar PolarArea Pie Doughnut/;
our @COLOR_NAME    = qw/fill_color stroke_color point_color point_stroke_color color/;
our %COLOR_TABLE   = (
    yellow => ['rgba(255,255,51,0.5)',  'rgba(255,204,51,1)',  'rgba(255,153,51,1)',  '#fff'],
    pink   => ['rgba(255,153,153,0.5)', 'rgba(255,102,153,1)', 'rgba(255,51,153,1)',  '#fff'],
    blue   => ['rgba(102,204,255,0.5)', 'rgba(102,153,255,1)', 'rgba(102,102,255,1)', '#fff'],
    green  => ['rgba(0,255,102,0.5)',   'rgba(0,204,102,1)',   'rgba(0,153,102,1)',   '#fff'],
    red    => ['rgba(204,102,0,0.5)',   'rgba(204,51,0,1)',    'rgba(204,0,0,1)',     '#fff'],
);

# $type  Line|Bar|Radar|PolarArea|Pie|Doughnut
# %opt   js     => /path/to/js
#        title  => HTML title
#        width  => canvas width
#        height => canvas height
#        and others same as Chart.js(specify camel case)
sub new {
    my ($class, $type, %opt) = @_;
    my $self = bless {}, $class;
    ($type) = grep {$type =~ /^$_$/i} @CHART_TYPE;
    die "Unknown chart type [$type]" if !$type;
    $self->type($type);
    $self->js(delete $opt{js});
    $self->title(delete $opt{title});
    $self->width(delete $opt{width});
    $self->height(delete $opt{height});
    $self->options(%opt);
    return $self;
}

sub create_element {
    my ($self, $name) = (shift, shift);
    my $color = @_ == 1        ? $COLOR_TABLE{$_[0]}
              : !@_ || @_ % 2  ? undef
              :                  {@_};
    die "Element's color theme is not specified" if !$color;
    my $element = $self->spawn($name);
    # Refer to COLOR_TABLE
    if (ref $color eq 'HASH'){
        %$color = map {lc($_) => $color->{$_}} keys %$color;
        my @keys = keys %$color;
        if (grep {$self->type eq $_} @CHART_TYPE[0, 1, 2]){
            die "Element's color option is wrong" if @keys != 4 || grep {my $k = $_; !grep {$k eq $_} @COLOR_NAME} @keys;
            $color = [@$color{@COLOR_NAME}];
        }
        else{
            die "Element's color option is wrong" if !exists $color->{color};
            $color = [$color->{color}];
        }
    }
    for (0..3){
        my $setter = $COLOR_NAME[$_];
        $element->$setter($color->[$_]);
    }
    $element->color($color->[0]); # for PolarArea, Pie, Doughnut
    return $element;
}

sub button_as_html {
    my ($self) = @_;
    my $buttons = "";
    for my $elm (@{$self->{elements}}){
        $buttons .= qq|<button style="background-color:@{[ $elm->stroke_color ]};" disabled>@{[ $elm->name ]}</button>|;
    }
    return $buttons;
}
sub data_as_json {
    my ($self) = @_;
    my $data;
    if (grep {$self->type eq $_} @CHART_TYPE[0, 1, 2]){ # Line Bar Radar
        $data->{labels} = $self->labels;
        for my $elm (@{$self->{elements}}){
             my $elm_data = {map {snake2camel($_) => $elm->{$_}} qw/fill_color stroke_color point_color point_stroke_color/};
             $elm_data->{data} = [map {$elm->{data}{$_} || 0} $self->labels];
             push @{$data->{datasets}}, $elm_data;
        }
    }
    else{
        for my $elm (@{$self->{elements}}){
            my $elm_data = {};
            $elm_data->{value} = $elm->{data}{value};
            $elm_data->{color} = $elm->color;
            push @$data, $elm_data;
        }
    }
    return jsonize($data);
}
sub options_as_json {jsonize($_[0]->options)}
sub render {
    my ($self) = @_;
    my $html = $self->template;
    for my $key (qw/title js width height type button_as_html data_as_json options_as_json/){
        $html =~ s/\$$key/$self->$key/eg;
    }
    return $html;
}

# Accessor
sub type    {$_[0]->{type}   = $_[1] || $_[0]->{type}}
sub js      {$_[0]->{js}     = $_[1] || $_[0]->{js}     || $CHART_JS}
sub title   {$_[0]->{title}  = $_[1] || $_[0]->{title}  || ""}
sub width   {$_[0]->{width}  = $_[1] || $_[0]->{width}  || $CANVAS_WIDTH}
sub height  {$_[0]->{height} = $_[1] || $_[0]->{height} || $CANVAS_HEIGHT}
sub options {
    my $self = shift;
    $self->{options} = ref $_[0] eq 'HASH' ? $_[0] : {\@_} if @_;
    return $self->{options} || {};
}
sub labels {
    my ($self) = @_;
    my %label;
    for my $elm (@{$self->{elements}}){
        $label{$_} = 1 for $elm->labels;
    }
    my @label_sorted = sort keys %label;
    return wantarray ? @label_sorted : \@label_sorted;
}
sub element {
    my ($self, $name) = @_;
    die "Element's name is not specified" if !$name;
    my ($element) = grep {$name eq $_->name} @{$self->{elements}};
    return $element;
}
sub spawn {
    my ($self, $name) = @_;
    die "Element [$name] is already exists" if grep {$name eq $_->name} @{$self->{elements}};
    my $element = bless {name => $name, type => $self->type}, (ref $self) . '::Element'; # bless ChartJS::Generator::Element class
    push @{$self->{elements}}, $element;
    return $element;
}

# Utility
sub escape_json {
    $_[0] =~ s/(['"\\])/\\$1/g if $_[0];
    return $_[0];
}

sub quote_str {
    my $thingy = shift;
    return !defined $thingy           ? "null"  # undef
         : ($thingy ^ $thingy) eq '0' ? $thingy # numeric
         : '"' . $thingy . '"';                 # string
}
sub jsonize {
    my $pl_data = shift;
    return ref $pl_data eq 'HASH'  ? hash2js($pl_data) : array2js($pl_data);
}
sub hash2js {
    my $hash = shift;
    die "Not a hash reference" if ref $hash ne 'HASH';
    my $js_str = "{";
    while (my ($key, $val) = each %$hash){
        my $ref = ref $val;
        if (!$ref){
            $js_str .= qq<$key:@{[$val =~ /true|false|null/ ? $val : quote_str(escape_json($val)) ]},>;
        }
        elsif($ref eq 'HASH'){
            $js_str .= qq|$key:@{[hash2js($val)]},|;
        }
        elsif($ref eq 'ARRAY'){
            $js_str .= qq|$key:@{[array2js($val)]},|;
        }
        else{
            die "Object type `$ref` is not supported for method jsonize";
        }
    }
    $js_str =~ s/,?$/}/;
    return $js_str;
}
sub array2js {
    my $array = shift;
    die "Not a array reference" if ref $array ne 'ARRAY';
    my $js_str = "[";
    for my $val (@$array){
        my $ref = ref $val;
        if (!$ref){
            $js_str .= qq<@{[$val =~ /true|false|null/ ? $val : quote_str(escape_json($val)) ]},>;
        }
        elsif($ref eq 'HASH'){
            $js_str .= qq|@{[hash2js($val)]},|;
        }
        elsif($ref eq 'ARRAY'){
            $js_str .= qq|@{[array2js($val)]},|;
        }
        else{
            die "Object type `$ref` is not supported for method jsonize";
        }
    }
    $js_str =~ s/,?$/]/;
    return $js_str;
}

sub snake2camel {
    (my $camel = $_[0] || '') =~ s/(?<!^)_(\w)/uc($1)/eg;
    return $camel;
}

# $xx part will replace by calling render method
sub template {
    <<'TMP';
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>$title</title>
<script src="$js"></script>
</head>
<body>
$title
<div>
 <canvas id="chart" width="$width" height="$height"></canvas>
</div>
<div>
$button_as_html
</div>
<script>
var ctx = document.getElementById("chart").getContext("2d");
var data = $data_as_json;
var option = $options_as_json;
new Chart(ctx).$type(data, option);
</script>
</body>
</html>
TMP
}

## This is the class for each chart element
package ChartJS::Generator::Element;
use strict;
use warnings;

# Accessor
sub name         {$_[0]->{name}}
sub type         {$_[0]->{type}}
sub data         {$_[0]->{data}}
sub labels       {wantarray ? keys %{$_[0]->{data}} : [keys %{$_[0]->{data}}]}
sub color        {$_[0]->{color}        = $_[1] || $_[0]->{color}}
sub fill_color   {$_[0]->{fill_color}   = $_[1] || $_[0]->{fill_color}}
sub stroke_color {$_[0]->{stroke_color} = $_[1] || $_[0]->{stroke_color}}
sub point_color  {$_[0]->{point_color}  = $_[1] || $_[0]->{point_color}}
sub point_stroke_color {$_[0]->{point_stroke_color} = $_[1] || $_[0]->{point_stroke_color}}

## Argument varies by chart type
#  Require label as first argument when chart type is Line, Bar, Radar.
#  In other type ignore label argumnet.
sub up {
    my $self = shift;
    my ($label, $cnt);
    if ($self->type =~ /^Line|Bar|Radar$/){
        $label = shift or die "Incremental target is not specified";
        $cnt = shift || 1;
        die "Argument Incremental count is not numeric" if $cnt !~ /^\d+$/;
    }
    else{
        $label = "value"; # label for PolarArea, Pie, Doughnut
        $cnt = shift || 1;
        die "Chart type `@{[$self->type]}` requires only numeric argument for increment" if $cnt !~ /^\d+$/;
    }
    $self->{data}{$label} += $cnt;
}
sub down {
    my $self = shift;
    my ($label, $cnt);
    if ($self->type =~ /^Line|Bar|Radar$/){
        $label = shift or die "Decremental target is not specified";
        $cnt = shift || 1;
        die "Argument Incremental count is not numeric" if $cnt !~ /^\d+$/;
    }
    else{
        $label = "value"; # label for PolarArea, Pie, Doughnut
        $cnt = shift || 1;
        die "Chart type `@{[$self->type]}` requires only numeric argument for decrement" if $cnt !~ /^\d+$/;
    }
    $self->{data}{$label} -= $cnt;
}

1;
__END__

=encoding utf-8

=head1 NAME

ChartJS::Generator - It's new $module

=head1 SYNOPSIS

    use ChartJS::Generator;

=head1 DESCRIPTION

ChartJS::Generator is ...

=head1 LICENSE

Copyright (C) Tooru Iwasaki.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Tooru Iwasaki E<lt>rockbone.g@gmail.comE<gt>

=cut

