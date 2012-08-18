#!/usr/bin/env perl

use strict;
use warnings;
use Amon2::Lite;
use MongoDB;
use lib './lib';
use Model;
use Data::Dumper;

get '/' => sub {
    my $c = shift;
    return $c->create_response(200, [], ['Hello, world']);
};

get '/add_usr' => sub {
    my $c     = shift;
    my $id    = $c->req->param('id');
    my $model = Model->new;

    if ($model->check_user_exists($id)) {
        return $c->redirect('/debug?exist_user');
    }
    $model->create_user($id, '');
    
    return $c->redirect('/debug');    
};


get '/debug' => sub {
    my $c    = shift;
    my $id   = $c->req->param('id');
    my $myid = $c->session->get('id');
    my $model = Model->new;

    # 自分の情報取得
    my $my_info = $model->check_user_exists($myid);
    
    # システム全体のユーザ情報取得
    my @users = $model->select_user_info();

    return $c->render('debug.tt' => {
	id      => $myid,
	my_info => $my_info,
	users   => \@users,
		      });
};

get '/drop' => sub {    
    my $c    = shift;
    my $myid = $c->session->get('id');
    drop_class($myid);
    return $c->redirect('/debug?dropped class.');
};

get '/follow' => sub {
    my $c     = shift;
    my $id    = $c->req->param('id');
    my $class = $c->req->param('class');
    my $myid  = $c->session->get('id');

    my $model = Model->new;

    # 自分をフォローしようとしたとき
    return $c->redirect('/debug?are_you_ok?') if $id eq $myid;
    
    # 自分の情報取得
    my $id_data = $model->check_user_exists($id);

    if ($id_data->{class}) {    
	# 自分がどこかに所属している時かつ
	if ($class) {
	    # 相手が所属している時
	    return $c->redirect('/debug?何もしない');
	} else {
	    # 相手が所属していない時
	    #相手を所属させる
	    $model->update_user_info($id, $class);
	    return $c->redirect('/debug?仲間が増えたよ!');
	}
    } else {
	# 自分がどこかに所属していないときかつ
	if ($class) {
	    # 相手が所属している時
	    $model->update_user_info($myid, $class);
	    return $c->redirect('/debug?仲間になったよ!');
	} else {
	    # 相手が所属していない時
	    # あたらしいクラスをつくる
	    my $newclass = `date "+%Y/%m/%d/%H:%M:%S"`;
	    $model->update_user_info($id  , $newclass);
	    $model->update_user_info($myid, $newclass);
	    return $c->redirect('/debug?仲間が増えたよ!');
	}
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

    my $model = Model->new;

    my $id = $model->history_insert(int($user_id), $lat, $lon);

    # user_id is not mine, lat or lon within 1km;
    my $users = $model->history_find_users(int($user_id), $lat, $lon);

    my $users_id;
    while (my $user = $users->next) {
        $users_id .= $user->{user_id} . ', ';
    }

    return $c->create_response(200, [], ['near user\'s id:' . $users_id]);
};

get '/login' => sub {
    my $c = shift;
    my $id = $c->req->param('id');

    my $con = MongoDB::Connection->new(host => 'localhost', port => 27017);
    unless ($con->test->usr->find_one({id => $id})) {
        return $c->redirect('/debug?nothing_user');
    }
    
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
