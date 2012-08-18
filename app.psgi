#!/usr/bin/env perl

use strict;
use warnings;
use Amon2::Lite;

get '/' => sub {
    my $c = shift;
    return $c->create_response(200, [], ['Hello, world']);
};

get '/debug' => sub {
    my $c = shift;
    return $c->render('debug.tt');
};

get '/login' => sub {
    my $c = shift;
    my $id = $c->req->param('id');
    
    if( $c->session->set('id' => $id ) )
    
    unless ($c->session->get('id')); 
    return $c->redirect('/debug');
};

__PACKAGE__->to_app(handle_static => 1);


