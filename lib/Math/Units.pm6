use v6.c;

use Math::Units::Defs;

# cw: The idea of specifying everything using the (yet-to-be-defined) class
#     is so that the class can build up a state table of unit-to-unit or
#     unit-to-formula mapping. Conversions would then be fairly straight
#     forward since singular unit-to-singular unit can be done by using
#     the inverse value, where VALUE = FAC * MAG.
#
#     This will get tricky though, since we have to build an initial table,
#     first. This means that we need a method to load the initial tables
#     before checking happens.
my $check_defs = 0;
#     Any instantiation of a Math::Units object
#     after module initialization will have checking *forced*.
#     So we then set $check_defs to a non-zero value when that is done.
initialize();

class UnitParser {
  has @.defUnits;
  has $.parser;

  grammar UnitParserGrammar {
    regex TOP { <num> [ '/' <den> ]? }

    regex num { ( <expr> \s* )+ }

    regex den { <expr> }

    regex expr {
      <mag>? <unit> [ '^' (\d+) ]?
    }

    token mag {
      T || G || M || k || h || da || d || c || m || u || µ || n || dn || p || f
    }

    proto token unit { * }

  }

  submethod BUILD {
    $!parser = UnitParserGrammar.new;
  }

  method addUnit(Str $unit) {
    $.parser.^add_multi_method("unit:sym<$unit>", my token { $unit });
    $.parser.^compose;
  }

  method parse($s) {
    $.parser.parse($s);
  }
}

class Math::Units {
  has %.units;

}

my sub initialize {
  my $up = UnitParser.new;
  for Units.enum.keys, %reductions.keys -> $k {
    $up.addUnit: $k;
  }

  # Lastly!
  $check_defs = 1;
}
