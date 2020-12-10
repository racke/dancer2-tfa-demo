package TFAdemo;
use Dancer2;
use Dancer2::Plugin::Auth::Extensible;

our $VERSION = '0.1';

get '/' => sub {
    my $user = logged_in_user;
    template index => {
                       title => config->{'title'},
                       user => $user->{user},
                      };
};

get '/private' => require_login sub {
    my $user = logged_in_user;
    template index => {
                       title => config->{'title'},
                       user => $user->{user},
                       message => "This is the secret part",
                      };
};

true;
