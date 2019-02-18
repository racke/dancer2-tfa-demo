requires "Dancer2" => "0.207000";

requires "YAML"             => "0";
requires "URL::Encode::XS"  => "0";
requires "CGI::Deurl::XS"   => "0";
requires "HTTP::Parser::XS" => "0";
requires "Dancer2::Template::TemplateFlute" => "0";
requires "Dancer2::Plugin::Auth::Extensible" => "0.706";

on "test" => sub {
    requires "Test::More"            => "0";
    requires "HTTP::Request::Common" => "0";
};
