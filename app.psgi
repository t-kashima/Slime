#!/usr/bin/env perl

use strict;
use warnings;
use Amon2::Lite;
use MongoDB;
use Data::Dumper;

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

get '/user' => sub {
    my $c = shift;
    return $c->render('geolocation.tt');
};

post '/user_geo' => sub {
    my $c = shift;
    my $user_id = $c->req->param('user_id');
    my $lat = $c->req->param('lat');
    my $lon = $c->req->param('lon');
    my $DB_HOST     = 'ds037087.mongolab.com';
    my $DB_USERNAME = 'mongo';
    my $DB_PASSWORD = 'mongo0819';
    my $DB_NAME     = 'slime_geo_user';
    my $DB_PORT     = 37087;

    # 0.00027778 => 31m
    my $ANGLE       = 0.00027778;

    my $connection = MongoDB::Connection->new(host => $DB_HOST, port => $DB_PORT,
                                          username => $DB_USERNAME, password => $DB_PASSWORD, db_name => $DB_NAME);

    my $database = $connection->slime_geo_user;
    my $collection = $database->history;

    my $id = $collection->insert({user_id => int($user_id), lat => $lat * 1, lon => $lon * 1});

    # user_id is not mine, lat or lon within 1km;
    my $users = $collection->find({'$and' => [{user_id => {'$ne' => int($user_id)}},
                                              {'$or' => [{lat => {'$gte' => $lat - $ANGLE * 35,
                                                                  '$lte' => $lat + $ANGLE * 35}},
                                                         {lon => {'$gte' => $lon - $ANGLE * 35,
                                                                  '$lte' => $lon + $ANGLE * 35}}]}]});

    my $users_id;
    while (my $user = $users->next) {
        $users_id .= $user->{user_id} . ', ';
    }

    return $c->create_response(200, [], ['near user\'s id:' . $users_id]);
};

__PACKAGE__->enable_session();
__PACKAGE__->to_app(handle_static => 1);
