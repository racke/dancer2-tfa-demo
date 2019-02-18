package Dancer2::Plugin::Auth::Extensible::Role::TFA;
use utf8;
use strict;
use warnings;
use Data::Dumper;
use Moo::Role;
use Convert::Base32 qw/encode_base32/;
use Imager::QRCode;
use URI::Escape qw/uri_escape/;
use Data::SimplePassword;

requires qw/authen_oath_validation_date
            authen_oath_secret
            set_authen_oath_validation_date
            set_authen_oath_secret
            /;

has username_key_name => (is => 'ro',
                          default => sub { 'username' });

has qr_code_label => (is => 'ro',
                      default => sub { 'Demo' });

sub check_tfa {
    my ($self, $username, $token) = @_;
    my $app = $self->plugin->app;
    my $secret = $self->authen_oath_secret($username);
    $app->log(debug => "User has secret $secret");
    # no secret stored, do nothing
    return 1 unless $secret;
    if ($token && $username) {
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
    my ($self) = @_;
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
