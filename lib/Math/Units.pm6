use v6.c;

use Math::Units::Defs;
use Math::Units::Parser;

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

my sub initialize {
  $up = Math::Units::Parser.new;

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
  for %unitTable.kv -> $k, $v {
    for $v.unitParts -> $p {
      die "Cannot find a definition for '{$p.unit}' in '{$k}'";
    }
  }

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
    :$units,
    :@unitParts
  ) {
      $!fac   = $fac;
      $!mag   = $mag;
      $!units = $units;
      $!value =  $.fac * $.mag;

      @.unitParts = @unitParts;
  }

  proto method new (|) {*}

  multi method new($e) {
    $up.parse($s);
  }

  multi method new(:$fac, :$mag, :$units) {
    my ($umag, @unitParts) = $up.parseUnits($units);
    self.bless(:$fac, :mag($mag * $umag), :$units, :@unitParts);
  }

  method !partsToString {
    $num = @.unitParts
      .grep({ $_[0] > 0 })
      .sort
      .map({ $_[1] ~ $[0] > 1 ?? "^{ $_[0] }" !! ''})
      .join(' ');

    $den = @.unitParts
      .grep({ $_[0] < 0})
      .sort
      .map({ $_[1] ~ $[0] < -1 ?? "^{ $_[0].Num.abs }" !! ''});

    "{ $num }/{ $den }";
  }

  method setUnits(Str $us) {
    my ($mag, $parts) = $up.parseUnits($us);

    # Check that given units are valid.
    @!unitParts = ();
    for $parts -> $up {
      die "Invalid unit '$up' in '$us'" unless %unitTable{$up}.defined;
      @.unitParts.push: $up;
    }
    $!units = self!partstoString;
  }

  method setUnits(@up) {
    # Check that given unit parts are valid.
    # Update $.units
  }

}

multi sub infix:<+>(Math::Units $lhs, Math::Units $rhs) {
  # If units are equivalent, add values
}


# Multiplication and division between Numeric values and a Math::Unit is fairly
# straight foward.
multi sub infix:<*>(Num $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($rhs.value * $lhs),
    :units($rhs.units),
    :unitParts(@rhs.unitParts)
  )
}

multi sub infix:<*>(Int $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($rhs.value * $lhs),
    :units($rhs.units),
    :unitParts(@rhs.unitParts)
  )
}

multi sub infix:</>(Num $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($rhs.value * $lhs),
    :units($rhs.units),
    :unitParts(@rhs.unitParts)
  )
}

multi sub infix:</>(Int $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($rhs.value * $lhs),
    :units($rhs.units),
    :unitParts(@rhs.unitParts)
  )
}
