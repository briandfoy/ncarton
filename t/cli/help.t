use strict;
use Test::More;
use lib ".";
use t::CLI;

{
    my $app = cli();
    $app->run("help");
    like $app->stdout, qr/NCarton - /;

    $app->run("-h");
    like $app->stdout, qr/NCarton - /;

    $app->run("help", "install");
    like $app->stdout, qr/Install the dependencies/;

    $app->run("install", "-h");
    like $app->stdout, qr/Install the dependencies/;

    $app->run("help", "foobarbaz");
    is $app->stdout, '';
    like $app->stderr, qr/No documentation found/;
}

done_testing;

