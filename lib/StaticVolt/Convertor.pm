# ABSTRACT: Base class for StaticVolt convertors

package StaticVolt::Convertor;

use Moo;
use Carp;
use Scalar::Util;
use namespace::autoclean;

has q(convertor) => (
    is  => q(ro),
    isa => sub {
        die q(Converter must be a hash reference)
            unless ref $_ eq q(HASH);
    },
    lazy    => 1,
    builder => q(_build_convertor),
    writer  => q(_set_convertor),
);

sub has_convertor {
    my ($self, $extension) = @_;

    return $self->convertor->{$extension}
        if exists $self->convertor->{$extension};
    return;
} ## end sub has_convertor

sub convert {
    my ($self, $content, $extension) = @_;

    my $converter = $self->has_convertor($extension);
    croak(qq(File extension "$extension" wasn't registered))
        unless $converter;

    eval qq(require $converter);
    if (my $e = $@) {
        croak(qq(Unable to load converter "$converter": $e));
    }
    no strict 'refs';
    &{"$converter::convert"}($content);
} ## end sub convert

sub register {
    my ($class, @extensions) = @_;

    $class = ref $class
        if blessed($class);

    my %converters = $self->convertor;
    for (@extensions) {
        $convertors{$extension} = $class;
    }
    $self->_set_convertor(\%converters);
    return scalar keys %converters;
} ## end sub register

sub _build_convertor { {} }

1;

__END__

=method C<has_convertor>

Accepts a filename extension and returns a boolean result which indicates
whether the particular extension has a registered convertor or not.

=method C<convert>

Accepts content and filename extension as the parametres. Returns HTML after
converting the content using the convertor registered for that extension.

=func C<register>

Accepts a list of filename extensions and registers a convertor for each
extension.
