package Dancer2::Plugin::Auth::Extensible::Role::TFA;
use utf8;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;
requires qw/authen_oath_validation_date
            authen_oath_secret
            set_authen_oath_validation_date
            set_authen_oath_secret
            /;


sub check_tfa {
    my $self = shift;
    $self->plugin->app->log("Checking TFA");
    my $request = $self->plugin->app->request;
    my $token;
    return 1;
}

sub BUILD {
    my $self = shift;
    my $plugin = $self->plugin;
    print "BUILDING TFA\n";
    my $app = $plugin->app;
    $app->add_route(method => 'get',
                    regexp => '/tfa/setup',
                    code => sub { tfa_setup($app, $plugin) });
    $app->add_route(method => 'post',
                    regexp => '/tfa/setup',
                    code => sub { tfa_do_setup($app, $plugin) });
    $app->add_route(method => 'get',
                    regexp => '/tfa/qrcode.png',
                    code => sub { tfa_qrcode($app, $plugin) });
    $app->add_route(method => 'get',
                    regexp => '/tfa/validate',
                    code => sub { tfa_validate($app, $plugin) });
    $app->add_route(method => 'post',
                    regexp => '/tfa/check-user',
                    code => sub { tfa_check_user($app, $plugin) });
}

sub tfa_setup {
    my ($app, $plugin) = @_;
    my $user = $plugin->logged_in_user;
    $app->log(debug => "in get_tfa " . Dumper([ $plugin->logged_in_user ]));
    return 'OK';
}

sub tfa_do_setup {
    my ($app, $plugin) = @_;
}

sub tfa_qrcode {
    my ($app, $plugin) = @_;
}

sub tfa_validate {
    my ($app, $plugin) = @_;
}

sub tfa_check_user {
    my ($app, $plugin) = @_;
}

1;
