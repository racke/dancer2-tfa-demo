package Dancer2::Plugin::Auth::Extensible::Role::TFA;
use utf8;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;
use Convert::Base32 qw/encode_base32/;
use Authen::OATH;
use Imager::QRCode;
use URI::Escape qw/uri_escape/;
use Data::SimplePassword;
use DateTime;

requires qw/authen_oath_validation_date
            authen_oath_secret
            set_authen_oath_validation_date
            set_authen_oath_secret
            /;

has username_key_name => (is => 'ro',
                          default => sub { 'username' });

has qr_code_label => (is => 'ro',
                      default => sub { 'Demo' });

has tfa_setup_view => (is => 'ro',
                       default => sub { 'tfa_setup' });

sub check_tfa {
    my ($self, $username, $token) = @_;
    return 0 unless $username;
    if ($self->authen_oath_secret($username) &&
        $self->authen_oath_validation_date($username)) {
        return $self->_do_check_tfa($username, $token);
    }
    else {
        return 1;
    }
}

sub _do_check_tfa {
    my ($self, $username, $token) = @_;
    return 0 unless $username;
    my $app = $self->plugin->app;
    my $secret = $self->authen_oath_secret($username);
    $app->log(debug => "User has secret $secret");
    # no secret stored, do nothing
    return 1 unless $secret;
    if ($token) {
        $app->log(debug => "Checking TFA");
        my $expected = Authen::OATH->new->totp($secret);
        if ($token eq $expected) {
            $app->log(info => "TFA check OK $token $expected");
            return 1;
        }
        else {
            $app->log(info => "Failed TFA check $token $expected");
        }
    }
    else {
        $app->log(debug => "Nothing to check, failing" . Dumper([ $username, $token ]));
    }
    return 0;
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
    $app->add_route(method => 'post',
                    regexp => '/tfa/check-user',
                    code => sub { $self->tfa_check_user });
}

sub tfa_setup {
    my ($self) = @_;
    my $app = $self->plugin->app;
    if (my $username = $self->_username_logged_in) {
        my %tokens;
        if ($self->authen_oath_secret($username)) {
            if (my $validation_date = $self->authen_oath_validation_date($username)) {
                %tokens = (
                    setup_ok => 1,
                    validation_date => $validation_date,
                );
            }
            else {
                %tokens = (
                           missing_validation => 1,
                           qrcode => $app->request->uri_for('/tfa/qrcode.png'),
                          );
            }
        }
        else {
            $self->set_authen_oath_secret($username, Data::SimplePassword->new->make_password(30));
            %tokens = (
                       missing_validation => 1,
                       qrcode => $app->request->uri_for('/tfa/qrcode.png'),
                      );
        }
        return $app->template($self->tfa_setup_view, \%tokens);
    }
    else {
        return $app->redirect($app->request->uri_for('/'));
    }
}

sub tfa_do_setup {
    my ($self) = @_;
    my $app = $self->plugin->app;
    # here we have only a post. Cancel or confirm. Anything else, redirect.
    if (my $username = $self->_username_logged_in) {
        my %tokens;
        if (my $secret = $self->authen_oath_secret($username)) {
            $app->log(debug => "$username has secret $secret");
            if ($self->authen_oath_validation_date($username)) {
                $app->log(debug => "$username has active token");
                if ($app->request->param('cancel')) {
                    $self->set_authen_oath_secret($username, undef);
                    $self->set_authen_oath_validation_date($username, undef);
                    %tokens = (cancelled => 1);
                }
            }
            elsif (my $token = $app->request->param('token')) {
                if ($self->_do_check_tfa($username, $token)) {
                    $self->set_authen_oath_validation_date($username, DateTime->now);
                    %tokens = (setup_ok => 1);
                }
                else {
                    %tokens = (
                               wrong_token => 1,
                               missing_validation => 1,
                               qrcode => $app->request->uri_for('/tfa/qrcode.png'),
                              );
                }
            }
        }
        if (%tokens) {
            return $app->template($self->tfa_setup_view, \%tokens);
        }
        else {
            return $app->redirect($app->request->uri_for('/tfa/setup'));
        }
    }
    return $app->redirect($app->request->uri_for('/'));
}

sub tfa_qrcode {
    my ($self) = @_;
    if (my $username = $self->_username_logged_in) {
        if (my $secret = $self->authen_oath_secret($username)) {
            if (!$self->authen_oath_validation_date($username)) {
                my $qr = Imager::QRCode->new(size => 6,
                                             margin => 2,
                                             version => 1,
                                             level => 'M',
                                             casesensitive => 1,
                                            );
                my $data;
                my $instance = $self->qr_code_label;
                my $user_link = uri_escape("$instance (" . $username . ')');
                my $img = $qr->plot("otpauth://totp/$user_link?secret=" . encode_base32($secret));
                $img->write(data => \$data, type => 'png');
                return $self->plugin->app->send_file (\$data, content_type => 'image/png');
            }
        }
    }
}

sub tfa_check_user {
    my ($self) = @_;
}

sub _username_logged_in {
    my ($self) = @_;
    my $k = $self->username_key_name;
    if (my $res = $self->plugin->logged_in_user) {
        return $res->{$k};
    }
}

1;
