package Dancer2::Plugin::Auth::Extensible::Role::TFA;
use utf8;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;
use Data::SimplePassword;

requires qw/authen_oath_validation_date
            authen_oath_secret
            set_authen_oath_validation_date
            set_authen_oath_secret
            /;

has username_key_name => (is => 'ro',
                          default => sub { 'username' });



sub check_tfa {
    my $self = shift;
    $self->plugin->app->log(debug => "Checking TFA");
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
                    code => sub { $self->tfa_setup });
    $app->add_route(method => 'post',
                    regexp => '/tfa/setup',
                    code => sub { $self->tfa_do_setup });
    $app->add_route(method => 'get',
                    regexp => '/tfa/qrcode.png',
                    code => sub { $self->tfa_qrcode });
    $app->add_route(method => 'get',
                    regexp => '/tfa/validate',
                    code => sub { $self->tfa_validate });
    $app->add_route(method => 'post',
                    regexp => '/tfa/check-user',
                    code => sub { $self->tfa_check_user });
}

sub tfa_setup {
    my ($self) = @_;
    if (my $username = $self->_username_logged_in) {
        if ($self->authen_oath_secret($username) &&
            $self->authen_oath_validation_date($username)) {
            return "Already setup";
        }
        else {
            $self->set_authen_oath_secret($username, Data::SimplePassword->new->make_password(30));
            return q{<img src="/tfa/qrcode.png">};
        }
    }
    else {
        return $self->plugin->app->redirect('/');
    }
}

sub tfa_do_setup {
    my ($self, $app, $plugin) = @_;
}

sub tfa_qrcode {
    my ($self, $app, $plugin) = @_;
}

sub tfa_validate {
    my ($self, $app, $plugin) = @_;
}

sub tfa_check_user {
    my ($self, $app, $plugin) = @_;
}

sub _username_logged_in {
    my ($self) = @_;
    my $k = $self->username_key_name;
    if (my $res = $self->plugin->logged_in_user) {
        return $res->{$k};
    }
}


1;
