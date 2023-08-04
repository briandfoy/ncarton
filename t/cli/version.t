use strict;
use Test::More;

use lib ".";
use t::CLI;

my $app = cli();
$app->run("version");

like $app->stdout, qr/carton $NCarton::VERSION/;

done_testing;

