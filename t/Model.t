package t::Model;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Model;
use Data::Dumper;
use YAML::XS;

my $file_config = 'config.yaml';
my $config = YAML::XS::LoadFile($file_config);

sub startup : Test(startup => 1) {
    use_ok 'Model';
}

sub find : Test(1) {
    my $model = Model->new(host => $config->{DB_HOST},
                           port => $config->{DB_PORT},
                           username => $config->{DB_USERNAME},
                           password => $config->{DB_PASSWORD},
                           db_name => $config->{DB_NAME});
    my $id = $model->history_insert(123, 35.6131, 139.6637765);
    my $user = $model->history_find_one($id);
    is ($user->{_id}, $id);
}

__PACKAGE__->runtests;
