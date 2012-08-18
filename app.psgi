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
    return $c->render('debug.tt' => {
	id => $c->session->get('id'),
		      });
};

get '/login' => sub {
    my $c = shift;
    my $id = $c->req->param('id');

    return $c->redirect('/debug?already_logined') if ($c->session->get('id'));     
    if( $c->session->set('id' => $id) ){
	return $c->redirect('/debug?loginsuccess');	
    } else {
	return $c->redirect('/debug?error');
    }
};

get '/logout' => sub {
    my $c = shift;
    
    if( $c->session->remove('id') ){
	return $c->redirect('/debug?logout_success');	
    } else {
	return $c->redirect('/debug?error');
    }
};

__PACKAGE__->enable_session();
__PACKAGE__->to_app(handle_static => 1);
