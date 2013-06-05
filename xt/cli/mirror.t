use strict;
use Test::More;
use xt::CLI;
use Cwd;

my $cwd = Cwd::cwd();

{
    my $app = cli();

    $app->dir->child("cpanfile")->spew(<<EOF);
requires 'Hash::MultiValue';
EOF

    $app->mirror("$cwd/xt/mirror");
    $app->run("install");

    $app->run("list");
    is $app->stdout, "Hash-MultiValue-0.08\n";
}

{
    # fallback to CPAN
    my $app = cli();
    $app->dir->child("cpanfile")->spew(<<EOF);
requires 'PSGI';
EOF

    $app->mirror("$cwd/xt/mirror");
    $app->run("install");

    $app->run("list");
    like $app->stdout, qr/^PSGI-/;
}

done_testing;



