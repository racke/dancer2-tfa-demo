package Dancer2::Plugin::Auth::Extensible::Provider::Demo;

use utf8;
use strict;
use warnings;
use Data::Dumper;

use Moo;
with qw/Dancer2::Plugin::Auth::Extensible::Role::TFA/;
extends qw/Dancer2::Plugin::Auth::Extensible::Provider::Config/;

around authenticate_user => sub {
    my ($orig, $self, $username, $password, @args) = @_;
    my $ret = $orig->($self, $username, $password, @args);
    return unless $ret;
    if ($self->check_tfa($username,
                         $self->plugin->app->request->param('token'))) {
        return $ret;
    }
    else {
        return;
    }
};

# these methods need to be provided

sub authen_oath_validation_date {
    my ($self, $username) = @_;
    if (my $details = $self->get_user_details($username)) {
        $self->plugin->app->log(debug => Dumper($details));
        return $details->{authen_oath_validation_date};
    }
    else {
        return;
    }
}

sub authen_oath_secret {
    my ($self, $username) = @_;
    if (my $details = $self->get_user_details($username)) {
        $self->plugin->app->log(debug => Dumper($details));
        return $details->{authen_oath_secret};
    }
    else {
        return;
    }
}

# stuff it in memory. It should work.

sub set_authen_oath_validation_date {
    my ($self, $username, $value) = @_;
    if (my $details = $self->get_user_details($username)) {
        $self->plugin->app->log(debug => Dumper($details));
        $details->{authen_oath_validation_date} = $value;
    }
}

sub set_authen_oath_secret {
    my ($self, $username, $value) = @_;
    if (my $details = $self->get_user_details($username)) {
        $self->plugin->app->log(debug => Dumper($details));
        $details->{authen_oath_secret} = $value;
    }
}



1;



