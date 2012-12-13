use strict;
use warnings;

use Test::More tests => 12;

use SelectSaver;

{
  diag("Nested blocks");

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  my $ss1 = SelectSaver->new($handle1);
  print "Var 1";
  is( $var1, "Var 1", "outer scope, first time" );

  {
    my $ss2 = SelectSaver->new($handle2);
    print "Var 2";
    is( $var2, "Var 2", "inner scope" );
  }

  print "-2";
  is( $var1, "Var 1-2", "outer scope, second time" );
}

{
  diag("Multiple selects per block, all my");

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  my $ss1 = SelectSaver->new($handle1);

  {
    my $ss11 = SelectSaver->new($handle1);
    print "Var 1";
    is( $var1, "Var 1", "first in scope (all my)" );

    my $ss2 = SelectSaver->new($handle2);
    print "Var 2";
    is( $var2, "Var 2", "second in scope (all my)" );
  }

  print "-2";
  is( $var1, "Var 1-2", "restored (all my)" );
}

{
  diag("Multiple selects per block, only one my per block");

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  my $ss1 = SelectSaver->new($handle1);

  {
    my $ss2 = SelectSaver->new($handle1);
    print "Var 1";
    is( $var1, "Var 1", "first in scope (one my)" );

    $ss2 = SelectSaver->new($handle2);
    print "Var 2";
    is( $var2, "Var 2", "second in scope (one my)" );
  }

  print "-2";
  is( $var1, "Var 1-2", "restored (one my)" );
}

{
  diag("Multiple selects, not my");

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  my $ss1 = SelectSaver->new($handle1);

  {
    $ss1 = SelectSaver->new($handle1);
    print "Var 1";
    is( $var1, "Var 1", "first in scope (not my)" );

    $ss1 = SelectSaver->new($handle2);
    print "Var 2";
    is( $var2, "Var 2", "second in scope (not my)" );
  }

  print "-2";
  is( $var2, "Var 2-2", "not restored because not my" );
}
