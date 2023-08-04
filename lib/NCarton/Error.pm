package NCarton::Error;
use strict;
use overload '""' => sub { $_[0]->error };
use Carp;

sub throw {
    my($class, @args) = @_;
    die $class->new(@args);
}

sub rethrow {
    die $_[0];
}

sub new {
    my($class, %args) = @_;
    bless \%args, $class;
}

sub error {
    $_[0]->{error} || ref $_[0];
}

package NCarton::Error::CommandNotFound;
use parent 'NCarton::Error';

package NCarton::Error::CommandExit;
use parent 'NCarton::Error';
sub code { $_[0]->{code} }

package NCarton::Error::CPANfileNotFound;
use parent 'NCarton::Error';

package NCarton::Error::SnapshotParseError;
use parent 'NCarton::Error';
sub path { $_[0]->{path} }

package NCarton::Error::SnapshotNotFound;
use parent 'NCarton::Error';
sub path { $_[0]->{path} }

1;
