use strictures;

package Number::Format::FixedLocale;

# VERSION

# ABSTRACT: a Number::Format that ignores the system locale

# COPYRIGHT

=head1 SYNOPSIS

    use Number::Format::FixedLocale;
    my $f = Number::Format::FixedLocale->new(
        -mon_thousands_sep => '.',
        -mon_decimal_point => ',',
        -int_curr_symbol   => 'EUR',
        -n_cs_precedes     => 0,
        -p_cs_precedes     => 0,
    );
    print $f->format_price( -45208.23 ); # "-45.208,23 EUR"

=head1 DESCRIPTION

L<Number::Format> is a very useful module, however in environments with many
systems it can be a liability due to the fact that it gathers its default
settings from the system locale, which can lead to surprising results when
formatting numbers in production.

Number::Format::FixedLocale is a sub-class of L<Number::Format> that contains
only a slightly modified constructor, which will only use a fixed set of en_US
default settings. Thus any results from this module will be predictable no
matter how the system it is being run on is configured.

=cut

use base 'Number::Format';

use Carp 'croak';

sub new
{
    my $type = shift;
    my %args = @_;

    # Fetch defaults from current locale, or failing that, using globals
    my $me            = {};

    my $arg;

    while(my($arg, $default) = each %$Number::Format::DEFAULT_LOCALE)
    {
        $me->{$arg} = $default;

        foreach ($arg, uc $arg, "-$arg", uc "-$arg")
        {
            next unless defined $args{$_};
            $me->{$arg} = $args{$_};
            delete $args{$_};
            last;
        }
    }

    #
    # Some broken locales define the decimal_point but not the
    # thousands_sep.  If decimal_point is set to "," the default
    # thousands_sep will be a conflict.  In that case, set
    # thousands_sep to empty string.  Suggested by Moritz Onken.
    #
    foreach my $prefix ("", "mon_")
    {
        $me->{"${prefix}thousands_sep"} = ""
            if ($me->{"${prefix}decimal_point"} eq
                $me->{"${prefix}thousands_sep"});
    }

    croak "Invalid argument(s)" if %args;
    bless $me, $type;
    $me;
}

1;
