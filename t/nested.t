use strict;
use warnings;

use Test::More tests => 12;

use Tie::Select;

{
  #Nested blocks

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  local $SELECT = $handle1;
  print "Var 1";
  is( $var1, "Var 1", "outer scope, first time" );

  {
    local $SELECT = $handle2;
    print "Var 2";
    is( $var2, "Var 2", "inner scope" );
  }

  print "-2";
  is( $var1, "Var 1-2", "outer scope, second time" );
}

{
  #Multiple selects per block, all local

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  local $SELECT = $handle1;

  {
    local $SELECT = $handle1;
    print "Var 1";
    is( $var1, "Var 1", "first in scope (all local)" );

    local $SELECT = $handle2;
    print "Var 2";
    is( $var2, "Var 2", "second in scope (all local)" );
  }

  print "-2";
  is( $var1, "Var 1-2", "restored (all local)" );
}

{
  #Multiple selects per block, only one local per block

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  local $SELECT = $handle1;

  {
    local $SELECT = $handle1;
    print "Var 1";
    is( $var1, "Var 1", "first in scope (one local)" );

    $SELECT = $handle2;
    print "Var 2";
    is( $var2, "Var 2", "second in scope (one local)" );
  }

  print "-2";
  is( $var1, "Var 1-2", "restored (one local)" );
}

{
  diag("Multiple selects, not local");

  open my $handle1, '>', \my $var1;
  open my $handle2, '>', \my $var2;

  local $SELECT = $handle1;

  {
    $SELECT = $handle1;
    print "Var 1";
    is( $var1, "Var 1", "first in scope (not local)" );

    $SELECT = $handle2;
    print "Var 2";
    is( $var2, "Var 2", "second in scope (not local)" );
  }

  print "-2";
  is( $var2, "Var 2-2", "not restored because not local" );
}
