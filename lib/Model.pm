package Model;
use strict;
use warnings;
use MongoDB;
use CGI::Carp qw(croak);
use Data::Dumper;

# 0.00027778 => 31m
my $ANGLE       = 0.00027778;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        host     => $args{host},
        username => $args{username},
        password => $args{password},
        db_name  => $args{db_name},
        port     => $args{port}
    }, $class;
    $self->{collection} = $self->setup;
    return $self;
}

sub setup {
    my $self = shift;
    my $connection = MongoDB::Connection->new(host => $self->{host}, port => $self->{port},
                                              username => $self->{username}, password => $self->{password},
                                              db_name => $self->{db_name});

    my $database = $connection->slime_geo_user;
    return $database->history;
}

sub insert_geo {
    my $self = shift;
    my ($user_id, $lat, $lon) = @_;

    return $self->{collection}->insert({user_id => int($user_id), lat => $lat * 1, lon => $lon * 1});
}

sub find_users {
    my $self = shift;
    my ($user_id, $lat, $lon) = @_;
    my $users = $self->{collection}->find({'$and' => [{user_id => {'$ne' => int($user_id)}},
                                                      {'$or' => [{lat => {'$gte' => $lat - $ANGLE * 35,
                                                                          '$lte' => $lat + $ANGLE * 35}},
                                                                 {lon => {'$gte' => $lon - $ANGLE * 35,
                                                                          '$lte' => $lon + $ANGLE * 35}}]}]});
    return $users;
}





# ユーザが存在しているときユーザ情報を、していない時、1
sub check_user_exists {
    my $self = shift;
    my $id   = shift;

    if (my $user = $self->test->user->find_one({id => $id})) {
	return 0;
    } else {
	return $user;
    }
}

sub select_user_info {
    my $self  = shift;
    my $where = shift || '';
    
    my $usrs = $self->test->usr->find($where);

    my @ret;
    while (my $u = $usrs->next) {
	push @ret, {id => $u->{id}, class => $u->{class}};
    }
    
    return @ret;
}


sub create_user {
    my $self  = shift;
    my $id    = shift;
    my $class = shift || '';

    if ($self->test->user->insert({id => $id, class => $class})) {
	return 0;
    } else {
	return 1;
    }
}


sub update_user_info {
    my $self  = shift;
    my $id    = shift;
    my $class = shift || '';
    
    if ($self->test->usr->update({id => $id}, {id => $id, class=>$class})){
	return 0;
    } else {
	return 1;
    }
}

	    

sub drop_class {
    my $self  = shift;
    my $id    = shift;

    if ($self->test->usr->update({id => $id}, {id => $id})) {
	return 0;
    } else {
	return 1;
    }
}


1;
