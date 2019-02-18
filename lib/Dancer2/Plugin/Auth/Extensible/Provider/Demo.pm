package Dancer2::Plugin::Auth::Extensible::Provider::Demo;

use utf8;
use strict;
use warnings;
use Data::Dumper;

use Moo;
with qw/Dancer2::Plugin::Auth::Extensible::Role::TFA/;
extends qw/Dancer2::Plugin::Auth::Extensible::Provider::Config/;

around authenticate_user => sub {
    my ($orig, $self, @args) = @_;
    $self->plugin->app->log(debug => Dumper(\@args));
    my $ret = $orig->($self, @args);
    if ($self->check_tfa) {
        return $ret;
    }
    else {
        return;
    }
};

# these needs to be provided

sub authen_oath_validation_date {
    my ($self, $username) = @_;
}

sub authen_oath_secret {
    my ($self, $username) = @_;
}

sub set_authen_oath_validation_date {
    my ($self, $username, $value) = @_;
}

sub set_authen_oath_secret {
    my ($self, $username, $value) = @_;
}

1;



