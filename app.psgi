#!/usr/bin/env perl

use strict;
use warnings;
use Amon2::Lite;

get '/' => sub {
    my $c = shift;
    return $c->create_response(200, [], ['Hello, world']);
};

__PACKAGE__->to_app(handle_static => 1);


