#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use TFAdemo;

TFAdemo->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use TFAdemo;
use Plack::Builder;

builder {
    enable 'Deflater';
    TFAdemo->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use TFAdemo;
use TFAdemo_admin;

use Plack::Builder;

builder {
    mount '/'      => TFAdemo->to_app;
    mount '/admin'      => TFAdemo_admin->to_app;
}

=end comment

=cut

