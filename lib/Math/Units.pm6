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
my $up;
my %unitTable;

#     Any instantiation of a Math::Units object
#     after module initialization will have checking *forced*.
#     So we then set $check_defs to a non-zero value when that is done.
initialize();

class Math::Units { ... }

# Cd ............. Celsius degrees (temperature change)
constant s   is export = Math::Units.new( :units<s>   );
constant m   is export = Math::Units.new( :units<m>   );
constant g   is export = Math::Units.new( :units<g>   );
constant deg is export = Math::Units.new( :units<deg> );
constant A   is export = Math::Units.new( :units<A>   );
constant C   is export = Math::Units.new( :units<C>   );
constant Cd  is export = Math::Units.new( :units<Cd>  );

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
    @.defUnits.push: $unit;
    $.parser.^add_multi_method("unit:sym<$unit>", my token { $unit });
    $.parser.^compose;
  }

  method parse($s) {
    $.parser.parse($s);
  }
}

my sub initialize {
  $up = UnitParser.new;

  # Add formula definitions to unit table
  for %formulas.kv,  -> $k, $v {
    $up.addUnit: $k;
    %unitTable{$k.Str} = Math::Units.new($v);
  }

  # Add reductions to the unit table
  for %reductions,kv -> $k, $v {
      $up.addUnit: $k;
      %unitTable{$k} = Math::Units.new($v);
  }

  # Check units table for validity.

  # Lastly!
  $check_defs = 1;
}

class Math::Units {
  has %.units;
  has $.fac;
  has $.mag;
  has $.value;
  has $.units;
  has @.unitParts;

  submethod BUILD(
    :$fac = 1,
    :$mag = 1,
    :$units
  ) {
      $!fac   = $fac;
      $!mag   = $mag;
      $!units = $units;

      $!value =  $.fac * $.mag;

      @.unitParts = self!parseUnits;
  }

  method !parseUnits {

  }
}
