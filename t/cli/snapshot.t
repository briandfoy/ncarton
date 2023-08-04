use strict;
use Test::More;
use lib ".";
use t::CLI;

subtest 'snapshot file has canonical representation' => sub {
    my $app = cli();
    $app->write_cpanfile(<<EOF);
requires 'Try::Tiny', '== 0.11';
requires 'Getopt::Long', '2.41';
EOF

    $app->run("install");

    my $content = $app->dir->child('cpanfile.snapshot')->slurp;
    for (1..3) {
        $app->dir->child('cpanfile.snapshot')->remove;
        $app->run("install");
        is $content, $app->dir->child('cpanfile.snapshot')->slurp;
    }
};

subtest 'Bad snapshot version' => sub {
    my $app = cli();
    $app->write_cpanfile('');
    $app->write_file('cpanfile.snapshot', <<EOF);
# carton snapshot format: version 111
EOF

    $app->run("install");
    like $app->stderr, qr/Could not parse/;
};

subtest 'Bad snapshot file' => sub {
    my $app = cli();
    $app->write_cpanfile('');
    $app->write_file('cpanfile.snapshot', <<EOF);
# carton snapshot format: version 1.0
DISTRIBUTIONS
  Foo-Bar-1
    unknown: foo
EOF

    $app->run("install");
    like $app->stderr, qr/Could not parse/;
};

subtest 'snapshot file support separate CRLF' => sub {
    my $app = cli();
    $app->write_cpanfile(<<EOF);
requires 'Try::Tiny', '== 0.11';
requires 'Getopt::Long', '2.41';
EOF

    $app->run("install");

    my $content = $app->dir->child('cpanfile.snapshot')->slurp;
    $content =~ s/\n/\r\n/g;
    $app->write_file('cpanfile.snapshot', $content);

    $app->run("install");
	is $app->exit_code, 0, 'install exits successfully';

	# Menlo has several uninitialized value warnings
	my @warnings =
		grep { ! m|Compat\.pm line \d+\.$| }
		split /\r?\n/, $app->stderr;
	is scalar @warnings, 0, 'there are no warnings';
};

done_testing;

