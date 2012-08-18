package t::Model;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Model;
use Data::Dumper;

my $DB_HOST     = 'ds037087.mongolab.com';
my $DB_USERNAME = 'mongo';
my $DB_PASSWORD = 'mongo0819';
my $DB_NAME     = 'slime_geo_user';
my $DB_PORT     = 37087;

sub startup : Test(startup => 1) {
    use_ok 'Model';
}

sub find : Test(1) {
    my $model = Model->new(host => $DB_HOST, port => $DB_PORT,
                           username => $DB_USERNAME, password => $DB_PASSWORD, db_name => $DB_NAME);
    my @users = $model->find_users(123, 35.6131, 139.6637765)->all;
    ok $#users, 3;
}

__PACKAGE__->runtests;
