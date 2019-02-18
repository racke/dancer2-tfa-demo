package Dancer2::Plugin::Auth::Extensible::Role::TFA;
use utf8;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;
use Class::Method::Modifiers;

# this doesn't work mixing extends and with
# requires qw/plugin/;
# use Data::Dumper;
#
# around authenticate_user => sub {
#     my $orig = shift;
#     my $self = shift;
#     my $ret = $orig->($self, @_);
#     $self->plugin->app->logger->info("Here!");
#     return $ret;
# };

sub check_tfa {
    my $self = shift;
    $self->plugin->app->log("Checking TFA");
    my $request = $self->plugin->app->request;
    my $token;
    return 1;
}

sub BUILD {
    my $self = shift;
    my $app = $self->plugin->app;
    $app->add_route(method => 'get',
                    regexp => '/tfa',
                    code => sub { $app->log(debug => Dumper($app->request)); return 'OK' });
}


1;
