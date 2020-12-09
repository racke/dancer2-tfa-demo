use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'TFAdemo',
    AUTHOR              => q{YOUR NAME <youremail@example.com>},
    VERSION_FROM        => 'lib/TFAdemo.pm',
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Authen::OATH' => 0,
        'CGI::Deurl::XS' => 0,
        'Convert::Base32' => 0,
        'Dancer2'     => '0.207000',
        'Dancer2::Plugin::Auth::Extensible' => '0.706',
        'Dancer2::Template::TemplateFlute' => 0,
        'Data::SimplePassword' => 0,
        'DateTime' => 0,
        'HTTP::Parser::XS' => 0,
        'HTTP::Request::Common' => 0,
        'Imager::QRCode' => 0,
        'Test::More' => 0,
        'URL::Encode::XS' => 0,
        'YAML'       => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'TFAdemo-*' },
);
