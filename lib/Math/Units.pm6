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

# Quick access unit table. Contains all defined units for quick conversion
# from literal to Math::Units objects.
#
# Ex: 1 * %U<m/s> == Math::Units.new('1 m/s') == Math::Units.new(:units<m/s>)
our %U is export := {};

my sub initialize {
  $up = Math::Units::Parser.new;

  # Consistency is good.
  %U{'s'}   := s;
  %U{'m'}   := m;
  %U{'g'}   := g;
  %U{'deg'} := deg;
  %U{'A'}   := A;
  %U{'C'}   := C;
  %U{'Cd'}  := Cd;

  # Add formula definitions to unit table
  for %formulas.kv,  -> $k, $v {
    $up.addUnit: $k;
    %unitTable{$k.Str} = Math::Units.new($v);
  }

  # Add reductions to the unit table
  for %reductions.kv -> $k, $v {
      $up.addUnit: $k;
      %unitTable{$k} = Math::Units.new($v);
  }

  # Check units table for validity.
  for %unitTable.kv -> $k, $v {
      .isValid(:fatal(True)) for $v.unitParts;
      die "Unit '{ $k }' was already defined during initialization!"
        if %U{$k}.defined;
      # Establish entry into quick access table if necessary.
      %U{$v.units} = Math::Units.new(:units($v.units));
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
      self.setValue($fac * $mag);
      $!units = $units;

      @.unitParts = @unitParts;

      self.isValid(:fatal($check_defs));
  }

  method setValue(Num $val) {
    $!value = $val;
    $!mag = 10 ** $val.log10.floor;
    $!fac = $value / $!mag;
  }

  method addUnit(Math::Units:U Str $u, *%def) {
    my ($mag, $parts) = $up.parseUnits($def<units>);

    die "Unit '$u' already exists" if %unitTable{$u}.defined;

    for $parts -> $p {
      die "Unknown unit '$p' in '$def<units>'"
        unless %unitTable{$p}.defined;
    }
    %unitTable{$u} = Math::Units.new(|%def);
    %U{$u} = Math::Units.new(:unit($u));
  }

  #proto method new (|) {*}

  multi method new($e) {
    $up.parse($s);
  }

  multi method new(:$fac, :$mag, :$units) {
    my ($umag, @unitParts) = $up.parseUnits($units);
    self.bless(:$fac, :mag($mag * $umag), :$units, :@unitParts);
  }

  method reduce {
    # Reduce unitParts to its most simple form.
    my @units = @.unitParts.clone.map({ $_[1] }).unique;
    my @newUnitParts;
    for @units -> $u {
      my @su = @.unitParts.grep({ $_[1] eq $u }).map({ $_[1] });
      my $s = @su.elems == 1 ?? @su[0][0] !! @su.sum;
      @newUnitParts.push: ($s, $u) if $s;
    }
    @!unitParts = @newUnitParts;
    $!units = self!partsToString;
  }

  method isValid(:$fatal = False) {
    for @.unitParts -> $p {
      my $msg = "Cannot find a definition for '{$p[1]}' in '{$.units}'";
      if $fatal {
        die $msg unless %unitTable{$p[1]}.defined;
      }
      else {
        say $msg;
        return False;
      }
    }
    True;
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
      .map({ $_[1] ~ $[0] < -1 ?? "^{ $_[0].Num.abs }" !! ''})
      .join(' ');

    my $ret = $num;
    $ret ~ "/{ $den }" if $den.chars;
    $ret;
  }

  method setUnits(Str $us) {
    my ($mag, $parts) = $up.parseUnits($us);

    # Check that given units are valid.
    @!unitParts = ();
    for $parts -> $up {
      die "Invalid unit '$up' in '$us'" unless %unitTable{$up}.defined;
      @.unitParts.push: $up;
    }
    $!units = self!partsToString;
  }

  method setUnits(@up) {
    # Check that given unit parts are valid.
    for @up -> $u {
      die "Invalid unit part '$u[1]'" unless %U{$u[1]}.defined;
    }
    @!unitParts = @up;
    # Update $.units
    $!units = self!partsToString;
  }

}

multi sub infix:<+>(Math::Units $lhs, Math::Units $rhs) {
  # If units are equivalent, add values
  $lhs.reduce;
  $rhs.reduce;
  die "Attempt to perform a sum using different units: { $lhs.units } vs { $rhs.units }"
    unless $lhs.units eq $rhs.units;
  Math::Units.new(:value($lhs.value - $rhs.value), :units($lhs.units));
}

multi sub infix:<->(Math::Units $lhs, Math::Units $rhs) {
  # If units are equivalent, subtract values
  $lhs.reduce;
  $rhs.reduce;
  die "Attempt to subtract using different units: { $lhs.units } vs { $rhs.units }"
    unless $lhs.units eq $rhs.units;
  Math::Units.new(:value($lhs.value - $rhs.value), :units($lhs.units));
}


# Multiplication and division between Numeric values and a Math::Unit is fairly
# straight foward.
multi sub infix:<*>(Num $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($rhs.value * $lhs),
    :units($rhs.units),
    :unitParts($rhs.unitParts)
  )
}

multi sub infix:<*>(Math::Units $lhs, Num $rhs) {
  $rhs * $lhs;
}

multi sub infix:<*>(Int $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($lhs * $rhs.value),
    :units($lhs.units),
    :unitParts($lhs.unitParts)
  )
}

multi sub infix:<*>(Math::Units $lhs, Int $rhs) {
  $rhs * $lhs;
}

multi sub infix:</>(Num $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($lhs / $rhs.value),
    :units($rhs.units),
    :unitParts($rhs.unitParts)
  )
}

multi sub infix:</>(Math::Units $lhs, Num $rhs) {
  Math::Units.new(
    :fac($lhs.value / $rhs),
    :units($lhs.units),
    :unitParts($lhs.unitParts)
  )
}

multi sub infix:</>(Int $lhs, Math::Units $rhs) {
  Math::Units.new(
    :fac($lhs / $rhs.value),
    :units($rhs.units),
    :unitParts($rhs.unitParts)
  )
}

multi sub infix:</>(Math::Units $lhs, Int $rhs) {
  Math::Units.new(
    :fac($lhs.value / $rhs),
    :units($lhs.units),
    :unitParts($lhs.unitParts)
  )
}
