use v6.c;

use Math::Units::Defs;
use Math::Units::Convert;
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
#
#  cw: These -could- be state variables, but why? Lexical scoping here is
#      all we need, right?
my $check_defs = 0;

#     Any instantiation of a Math::Units object
#     after module initialization will have checking *forced*.
#     So we then set $check_defs to a non-zero value when that is done.
INIT { initialize(); }

# Quick access unit table. Contains all defined units for quick conversion
# from literal to Math::Units objects.
#
# Ex: %U<m/s> == 1 * %U<m/s> == Math::Units.new('1 m/s') == Math::Units.new(:units<m/s>)
our %U is export;

class Math::Units {
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
      my ($umag, $parts);
      if $units.defined {
        $!units = $units;
        ($umag, $parts) = $up.parseUnits($units);
        @!unitParts = |@( $parts );
      }
      elsif @unitParts.defined {
        @!unitParts = @unitParts;
        $!units = self!partsToString;
      }

      self.setValue($fac.Num * $mag.Num * ($umag // 1));
      self.isValid if $check_defs;
  }

  method setValue(Num $val) {
    $!value = $val;
    $!mag = 10 ** $val.log10.floor;
    $!fac = $.value / $.mag;
  }

  method addUnit(Math::Units:U: Str $u, *%def) {
    my ($mag, $parts) = $up.parseUnits(%def<units>);

    die "Unit '$u' already exists" if %unitTable{$u}.defined;

    for $parts -> $p {
      die "Unknown unit '$p' in '%def<units>'"
        unless %unitTable{$p}.defined;
    }
    %unitTable{$u} = Math::Units.new(|%def);
    %U{$u} = Math::Units.new(:unit($u));
  }

  method !handleMag($mag) {
    given $mag {
      when Str {
        Magnitude.enums{$mag};
      }

      when Int | Num {
        $mag;
      }
    }
  }

  multi method new(Str $e) {
    self.bless(|%( $up.parse($e) ));
  }

  multi method new(:$fac = 1, :$mag = 1, :$units!) {
    my $nmag = self!handleMag($mag);
    self.bless(:$fac, :$mag, :$units);
  }

  multi method new(:$fac = 1, :$mag = 1, :@unitParts!) {
    my $nmag = self!handleMag($mag);
    self.bless(:$fac, :$mag, :@unitParts);
  }

  method reduce {
    # Reduce unitParts to its simplest form.
    my @units = @.unitParts.clone.map({ $_[0] }).unique;
    my @newUnitParts;
    for @units -> $u {
      my $s = @.unitParts.grep({ $_[0] eq $u }).map({ $_[1] }).sum;
      @newUnitParts.push: ($u, $s) if $s;
    }
    @!unitParts = @newUnitParts;
    $!units = self!partsToString;
  }

  method isValid(:$fatal = True) {
    for @.unitParts -> $p {
      my $msg = "Can't find a definition for '{$p[0]}' in '{$.units}'";
      if $fatal {
        die $msg unless %unitTable{$p[0]}.defined;
      }
      else {
        say $msg;
        return False;
      }
    }
    True;
  }

  method !partsToString {
    my $num = @.unitParts
      .grep({ $_[1] > 0 })
      .sort({ $^a[0] cmp $^b[0] })
      .map({ $_[0] ~ ($_[1] > 1 ?? "^{ $_[1] }" !! '') })
      .join(' ');

    my $den = @.unitParts
      .grep({ $_[1] < 0})
      .sort({ $^a[0] cmp $^b[0] })
      .map({ $_[0] ~ ($_[1] < -1 ?? "^{ $_[1].Num.abs }" !! '') })
      .join(' ');

    my $ret = $num;
    $ret ~= "/{ $den }" if $den.chars;
    $ret;
  }

  multi method setUnits(Str $us) {
    my ($mag, $parts) = $up.parseUnits($us);

    # Check that given units are valid.
    @!unitParts = ();
    for $parts -> $up {
      die "Invalid unit '$up' in '$us'" unless %unitTable{$up}.defined;
      @.unitParts.push: $up;
    }
    $!units = self!partsToString;
  }

  multi method setUnits(@up) {
    # Check that given unit parts are valid.
    for @up -> $u {
      die "Invalid unit part '$u[0]'" unless %U{$u[0]}.defined;
    }
    @!unitParts = @up;
    # Update $.units
    $!units = self!partsToString;
  }

  method pow(Num $pow) {
    self.setValue($.value.pow($pow));
    for @.unitParts -> $p {
      $p[1] *= $pow;
    }
    $!units = self!partsToString;
  }

  # cw: This entire train needs more thought. For example, could we make
  #     Math::Units::Convert independent of Math::Units, somehow?
  #
  #     Maybe move the Math::Units::Defs part to Math::Units::Convert
  #     and make Math::Units only dependent on Math::Units::Convert?
  #
  #     that might work.
  #
  # If there is a Math::Units::Convert, then this routine should reference
  # it.
  method convert($newUnit) {
    convertUnits($.value, $.units, $newUnit);
  }

}

multi sub infix:<+>(Math::Units $lhs, Math::Units $rhs) is export {
  # If units are equivalent, add values
  $lhs.reduce;
  $rhs.reduce;
  die "Attempt to perform a sum using different units: { $lhs.units } vs { $rhs.units }"
    unless $lhs.units eq $rhs.units;

  Math::Units.new(:fac($lhs.value + $rhs.value), :units($lhs.units));
}

multi sub infix:<->(Math::Units $lhs, Math::Units $rhs) is export {
  # If units are equivalent, subtract values
  $lhs.reduce;
  $rhs.reduce;
  die "Attempt to subtract using different units: { $lhs.units } vs { $rhs.units }"
    unless $lhs.units eq $rhs.units;
  Math::Units.new(:fac($lhs.value - $rhs.value), :units($lhs.units));
}

multi sub infix:<*>(Math::Units $lhs, Math::Units $rhs) is export {
  my @unitParts;
  my @totalParts = |$lhs.unitParts, |$rhs.unitParts;
  for @totalParts.clone.map({ $_[0] }).unique -> $u {
    my $uPow = @totalParts.grep({ $_[0] eq $u }).map({ $_[1] }).sum;
    @unitParts.push: ($u, $uPow) if $uPow;
  }

  Math::Units.new(:fac($lhs.value * $rhs.value), :@unitParts);
}

# Multiplication and division between Numeric values and a Math::Unit is fairly
# straight foward.
multi sub infix:<*>(Num $lhs, Math::Units $rhs) is export {
  Math::Units.new(
    :fac($rhs.value * $lhs),
    :units($rhs.units),
    :unitParts($rhs.unitParts)
  )
}

multi sub infix:<*>(Math::Units $lhs, Num $rhs) is export {
  $rhs * $lhs;
}

multi sub infix:<*>(Int $lhs, Math::Units $rhs) is export {
  Math::Units.new(
    :fac($lhs * $rhs.value),
    :units($rhs.units),
    :unitParts($rhs.unitParts)
  )
}

multi sub infix:<*>(Math::Units $lhs, Int $rhs) is export {
  $rhs * $lhs;
}

multi sub infix:</>(Math::Units $num, Math::Units $den) {
  my @unitParts;
  my @totalParts = |$num.unitParts, |$den.unitParts.map({ [ $_[0], $_[1] *-1 ] });
  for @totalParts.clone.map({ $_[0] }).unique -> $u {
    my $uPow = @totalParts.grep({ $_[0] eq $u }).map({ $_[1] }).sum;
    @unitParts.push: ($u, $uPow) if $uPow;
  }

  Math::Units.new(:fac($num.value / $den.value), :@unitParts);
}

multi sub infix:</>(Num $lhs, Math::Units $rhs) is export {
  Math::Units.new(
    :fac($lhs / $rhs.value),
    :units($rhs.units),
    :unitParts($rhs.unitParts)
  )
}

multi sub infix:</>(Math::Units $lhs, Num $rhs) is export {
  Math::Units.new(
    :fac($lhs.value / $rhs),
    :units($lhs.units),
    :unitParts($lhs.unitParts)
  )
}

multi sub infix:</>(Int $lhs, Math::Units $rhs) is export {
  Math::Units.new(
    :fac($lhs / $rhs.value),
    :units($rhs.units),
    :unitParts($rhs.unitParts)
  )
}

multi sub infix:</>(Math::Units $lhs, Int $rhs) is export {
  Math::Units.new(
    :fac($lhs.value / $rhs),
    :units($lhs.units),
    :unitParts($lhs.unitParts)
  )
}

# Cd ............. Celsius degrees (temperature change)
#constant s   is export = Math::Units.new( :units<s>   );
#constant m   is export = Math::Units.new( :units<m>   );
#constant g   is export = Math::Units.new( :units<g>   );
#constant deg is export = Math::Units.new( :units<deg> );
#constant A   is export = Math::Units.new( :units<A>   );
#constant C   is export = Math::Units.new( :units<C>   );
#constant Cd  is export = Math::Units.new( :units<Cd>  );

sub initialize {
  dsay("==== Math::Units INIT ====");
  #$up = Math::Units::Parser.new;
  $up.addUnit('s');
  $up.addUnit('m');
  $up.addUnit('g');
  $up.addUnit('deg');
  $up.addUnit('A');
  $up.addUnit('C');
  $up.addUnit('Cd');
  $up.addUnit('cycle');

  %U<s>     = Math::Units.new( :units<s>      );
  %U<m>     = Math::Units.new( :units<m>      );
  %U<g>     = Math::Units.new( :units<g>      );
  %U<deg>   = Math::Units.new( :units<deg>    );
  %U<A>     = Math::Units.new( :units<A>      );
  %U<C>     = Math::Units.new( :units<C>      );
  %U<Cd>    = Math::Units.new( :units<Cd>     );
  %U<cycle> = Math::Units.new( :units<cycle>  );

  # Add formula definitions to unit table
  for @formulas -> $fp {
    dsay("Adding unit { $fp.key }");

    $up.addUnit: $fp.key;
    %unitTable{$fp.key} = Math::Units.new(|%( $fp.value ));
  }

  # Add reductions to the unit table.
  # Add reduction and its inverse to factor conversion table.
  for @reductions -> $r {
      dsay("Adding unit { $r.key }");

      $up.addUnit: $r.key;
      %unitTable{$r.key} = Math::Units.new(|%( $r.value ));
  }

  for @formulas2 -> $fp {
    dsay("Adding unit { $fp.key }");

    $up.addUnit: $fp.key;
    %unitTable{$fp.key} = Math::Units.new(|%( $fp.value ));
  }

  # Add all unit identities to quick access structure.
  for %unitTable.kv -> $k, $v {
      %U{$k} = Math::Units.new(:units($k));
  }

  # Lastly!
  $check_defs = 1;

  dsay("==== Math::Units ENDINIT ====");
}
