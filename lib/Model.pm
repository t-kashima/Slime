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
    $self->{database} = $self->setup_database;
    return $self;
}

sub setup_database {
    my $self = shift;
    my $connection = MongoDB::Connection->new(host => $self->{host}, port => $self->{port},
                                              username => $self->{username}, password => $self->{password},
                                              db_name => $self->{db_name});

    return $connection->slime_geo_user;
}

sub history_insert {
    my $self = shift;
    my ($user_id, $lat, $lon) = @_;
    my $collection = $self->{database}->history;
    return $collection->insert({user_id => int($user_id), lat => $lat * 1, lon => $lon * 1});
}

sub history_find_users {
    my $self = shift;
    my ($user_id, $lat, $lon) = @_;
    my $collection = $self->{database}->history;
    my $users = $collection->find({'$and' => [{user_id => {'$ne' => int($user_id)}},
                                              {'$or' => [{lat => {'$gte' => $lat - $ANGLE * 35,
                                                                  '$lte' => $lat + $ANGLE * 35}},
                                                         {lon => {'$gte' => $lon - $ANGLE * 35,
                                                                  '$lte' => $lon + $ANGLE * 35}}]}]});
    return $users;
}

sub history_find_one {
    my $self = shift;
    my $id = shift;
    my $collection = $self->{database}->history;
    return $collection->find_one({_id => $id});
}

1;
