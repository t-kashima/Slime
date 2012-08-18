package Model;
use strict;
use warnings;
use MongoDB;
use CGI::Carp qw(croak);
use YAML::XS;
use Data::Dumper;

my $file_config = 'config.yaml';
my $config = YAML::XS::LoadFile($file_config);

# 0.01 => 1km
my $RANGE       = 0.01;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        host => $config->{DB_HOST},
        port => $config->{DB_PORT},
        username => $config->{DB_USERNAME},
        password => $config->{DB_PASSWORD},
        db_name => $config->{DB_NAME}
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
                                              {'$or' => [{lat => {'$gte' => $lat - $RANGE,
                                                                  '$lte' => $lat + $RANGE}},
                                                         {lon => {'$gte' => $lon - $RANGE,
                                                                  '$lte' => $lon + $RANGE}}]}]});
    return $users;
}

sub history_find_one {
    my $self = shift;
    my $id = shift;
    my $collection = $self->{database}->history;
    return $collection->find_one({_id => $id});
}

1;
