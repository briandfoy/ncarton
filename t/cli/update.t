use strict;
use Test::More;
use lib ".";
use t::CLI;

subtest 'carton update NonExistentModule' => sub {
    my $app = cli();

    $app->write_cpanfile(<<EOF);
requires 'Try::Tiny', '== 0.09';
EOF

    $app->run("install");
    $app->run("update", "XYZ");
    like $app->stderr, qr/Could not find module XYZ/, 'update notes that non-existent module is not found';
};

subtest 'carton update upgrades a dist' => sub {
    my $app = cli();

	my $before_pattern = qr/Try-Tiny-0\.09/;
	my $after_pattern  = qr/Try-Tiny-0\.12/;

    $app->write_cpanfile(<<EOF);
requires 'Try::Tiny', '== 0.09';
EOF

    $app->run("install");
    $app->run("list");
    like $app->stdout, $before_pattern, 'list shows the exact version in cpanfile';

    $app->write_cpanfile(<<EOF);
requires 'Try::Tiny', '>= 0.09, <= 0.12';
EOF

    $app->run("install");
    $app->run("check");
	like $app->stdout, qr/are satisfied/, 'check after another install shows that version is satisfied';

    $app->run("list");
    like $app->stdout, $before_pattern, 'list shows the same version we had before';

    $app->run("update", "Try::Tiny");
    like $app->stdout, qr/installed Try-Tiny-0\.12.*upgraded from 0\.09/, 'update shows that module was upgraded';

    $app->run("check");
    like $app->stdout, qr/are satisfied/, 'check after update shows that version is satisfied';

    $app->run("list");
    like $app->stdout, $after_pattern, 'list shows that module was updated to higher version';
};

subtest 'downgrade a distribution' => sub {
    my $app = cli();

	my $specified = '0.16';
    $app->write_cpanfile(<<"EOF");
requires 'Try::Tiny', '$specified';
EOF
    $app->run("install");
    $app->run("list");
    like $app->stdout, qr/Try-Tiny-0\.\d\d/, 'list shows some version after install';

    my( $version ) = $app->stdout =~ m/Try-Tiny-0\.(\d\d)/;
    cmp_ok $version, '>=', $specified, "installed version is greater or equal ($version >= $specified)";

    $app->write_cpanfile(<<EOF);
requires 'Try::Tiny', '== 0.09';
EOF
    $app->run("update");
    $app->run("list");
    like $app->stdout, qr/Try-Tiny-0\.09/, 'list shows downgrade after update';

 TODO: {
        local $TODO = 'collecting wrong install info';
        $app->write_cpanfile(<<EOF);
requires 'Try::Tiny', '0.09';
EOF
        $app->run("install");
 		$app->run("list");
        like $app->stdout, qr/Try-Tiny-0\.09/;
    }
};

done_testing;

