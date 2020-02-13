use strict;
use warnings;
package YAML::PP::Representer;

our $VERSION = '0.019'; # VERSION

use Scalar::Util qw/ reftype blessed refaddr /;

use YAML::PP::Common qw/
    YAML_PLAIN_SCALAR_STYLE YAML_SINGLE_QUOTED_SCALAR_STYLE
    YAML_DOUBLE_QUOTED_SCALAR_STYLE
    YAML_ANY_SCALAR_STYLE
    YAML_LITERAL_SCALAR_STYLE YAML_FOLDED_SCALAR_STYLE
    YAML_FLOW_SEQUENCE_STYLE YAML_FLOW_MAPPING_STYLE
    YAML_BLOCK_MAPPING_STYLE YAML_BLOCK_SEQUENCE_STYLE
/;
use B;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        schema => $args{schema},
    }, $class;
    return $self;
}

sub clone {
    my ($self) = @_;
    my $clone = {
        schema => $self->schema,
    };
    return bless $clone, ref $self;
}

sub schema { return $_[0]->{schema} }

sub represent_node {
    my ($self, $node) = @_;

    $node->{reftype} = reftype($node->{value});

    if (ref $node->{value}) {
        $self->represent_noderef($node);
    }
    else {
        $self->represent_node_nonref($node);
    }
    $node->{reftype} = (reftype $node->{data}) || '';

    if ($node->{reftype} eq 'HASH' and my $tied = tied(%{ $node->{data} })) {
        my $representers = $self->schema->representers;
        $tied = ref $tied;
        if (my $def = $representers->{tied_equals}->{ $tied }) {
            my $code = $def->{code};
            my $done = $code->($self, $node);
        }
    }

    if ($node->{reftype} eq 'HASH') {
        unless (defined $node->{items}) {
            # by default we sort hash keys
            for my $key (sort keys %{ $node->{data} }) {
                push @{ $node->{items} }, $key, $node->{data}->{ $key };
            }
        }
        return [ mapping => $node ];
    }
    elsif ($node->{reftype} eq 'ARRAY') {
        unless (defined $node->{items}) {
            @{ $node->{items} } = @{ $node->{data} };
        }
        return [ sequence => $node ];
    }
    elsif ($node->{reftype}) {
        die "Reftype $node->{reftype} not implemented";
    }
    else {
        unless (defined $node->{items}) {
            $node->{items} = [$node->{data}];
        }
        return [ scalar => $node ];
    }

}

sub represent_node_nonref {
    my ($self, $node) = @_;
    my $representers = $self->schema->representers;

    if (not defined $node->{value}) {
        if (my $undef = $representers->{undef}) {
            return 1 if $undef->($self, $node);
        }
        else {
            $node->{style} = YAML_SINGLE_QUOTED_SCALAR_STYLE;
            $node->{data} = '';
            return 1;
        }
    }
    for my $rep (@{ $representers->{flags} }) {
        my $check_flags = $rep->{flags};
        my $flags = B::svref_2object(\$node->{value})->FLAGS;
        if ($flags & $check_flags) {
            return 1 if $rep->{code}->($self, $node);
        }

    }
    if (my $rep = $representers->{equals}->{ $node->{value} }) {
        return 1 if $rep->{code}->($self, $node);
    }
    for my $rep (@{ $representers->{regex} }) {
        if ($node->{value} =~ $rep->{regex}) {
            return 1 if $rep->{code}->($self, $node);
        }
    }
    unless (defined $node->{data}) {
        $node->{data} = $node->{value};
    }
    unless (defined $node->{style}) {
        $node->{style} = YAML_ANY_SCALAR_STYLE;
        $node->{style} = "";
    }
}

sub represent_noderef {
    my ($self, $node) = @_;
    my $representers = $self->schema->representers;

    if (my $classname = blessed($node->{value})) {
        if (my $def = $representers->{class_equals}->{ $classname }) {
            my $code = $def->{code};
            return 1 if $code->($self, $node);
        }
        for my $matches (@{ $representers->{class_matches} }) {
            my ($re, $code) = @$matches;
            if (ref $re and $classname =~ $re or $re) {
                return 1 if $code->($self, $node);
            }
        }
        for my $isa (@{ $representers->{class_isa} }) {
            my ($class_name, $code) = @$isa;
            if ($node->{ value }->isa($class_name)) {
                return 1 if $code->($self, $node);
            }
        }
    }
    if ($node->{reftype} eq 'SCALAR' and my $scalarref = $representers->{scalarref}) {
        my $code = $scalarref->{code};
        return 1 if $code->($self, $node);
    }
    if ($node->{reftype} eq 'REF' and my $refref = $representers->{refref}) {
        my $code = $refref->{code};
        return 1 if $code->($self, $node);
    }
    if ($node->{reftype} eq 'CODE' and my $coderef = $representers->{coderef}) {
        my $code = $coderef->{code};
        return 1 if $code->($self, $node);
    }
    $node->{data} = $node->{value};

}

1;
