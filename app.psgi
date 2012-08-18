#!/usr/bin/env perl

use strict;
use warnings;
use Amon2::Lite;
use MongoDB;
use lib './lib';
use Model;
use Data::Dumper;

my $DB_HOST     = 'ds037087.mongolab.com';
my $DB_USERNAME = 'mongo';
my $DB_PASSWORD = 'mongo0819';
my $DB_NAME     = 'slime_geo_user';
my $DB_PORT     = 37087;

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

get '/user' => sub {
    my $c = shift;
    return $c->render('geolocation.tt');
};

post '/user_geo' => sub {
    my $c = shift;
    my $user_id = $c->req->param('user_id');
    my $lat = $c->req->param('lat');
    my $lon = $c->req->param('lon');

    my $model = Model->new(host => $DB_HOST, port => $DB_PORT,
                           username => $DB_USERNAME, password => $DB_PASSWORD, db_name => $DB_NAME);

    my $id = $model->insert_geo(int($user_id), $lat, $lon);

    # user_id is not mine, lat or lon within 1km;
    my $users = $model->find_users(int($user_id), $lat, $lon);

    my $users_id;
    while (my $user = $users->next) {
        $users_id .= $user->{user_id} . ', ';
    }

    return $c->create_response(200, [], ['near user\'s id:' . $users_id]);
};

get '/login' => sub {
    my $c = shift;
    my $id = $c->req->param('id');
    $c->session->set('id' => $id);
    return $c->redirect('/debug');
};

get '/logout' => sub {
    my $c = shift;
    $c->session->remove('id');
    return $c->redirect('/debug');
};

__PACKAGE__->enable_session();
__PACKAGE__->to_app(handle_static => 1);
