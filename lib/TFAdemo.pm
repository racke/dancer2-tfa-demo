package TFAdemo;
use Dancer2;
use Dancer2::Plugin::Auth::Extensible;

our $VERSION = '0.1';

get '/' => sub {
    template 'index' => { 'title' => 'TFAdemo' };
};

get '/private' => require_login sub {
    return "Very secret!"
};

true;
