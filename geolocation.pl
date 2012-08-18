#!/usr/bin/env perl

use strict;
use warnings;
use Amon2::Lite;

get '/' => sub {
    my $c = shift;
    return $c->create_response(200, [], ['Hello, world']);
};

post '/user' => sub {
    my $c = shift;
    my $data;
    $data .= $c->req->param('lat');
    $data .= $c->req->param('lon');
    return $c->create_response(200, [], [$data]);
};

__PACKAGE__->to_app(handle_static => 1);


