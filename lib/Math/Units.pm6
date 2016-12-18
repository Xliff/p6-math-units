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
#
#  cw: These -could- be state variables, but why? Lexical scoping here is
#      all we need, right?
my $check_defs = 0;
my $up;

# cw: -YYY- Now that we have %U, what do we need this for?
#     Should this hold unit identities?
my %unitTable;

#     Any instantiation of a Math::Units object
#     after module initialization will have checking *forced*.
#     So we then set $check_defs to a non-zero value when that is done.
INIT { initialize(); }

# Quick access unit table. Contains all defined units for quick conversion
# from literal to Math::Units objects.
#
# Ex: 1 * %U<m/s> == Math::Units.new('1 m/s') == Math::Units.new(:units<m/s>)
our %U is export;

my %factors;

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
      say "Math::Units::BUILD start\n";
      self.setValue($fac.Num * $mag.Num);
      $!units = $units;

      @!unitParts = |@unitParts;

      self.isValid if $check_defs;
      say "Math::Units::BUILD end\n";;
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

  #proto method new (|) {*}

  multi method new(Str $e) {
    dd $e;
    $up.parse($e);
  }

  multi method new(:$fac = 1, :$mag = 1, :$units) {
    dd $fac;
    dd $mag;
    dd $units;

    my ($umag, $unitParts) = $up.parseUnits($units);
    my @unitParts = @( $unitParts );

    my $nmag = do given $mag {
      when Str {
        Magnitude.enums{$mag};
      }

      when Int | Num {
        $mag;
      }
    }
    self.bless(:$fac, :mag($nmag * $umag), :$units, :@unitParts);
  }

  method reduce {
    # Reduce unitParts to its most simple form.
    my @units = @.unitParts.clone.map({ $_[0] }).unique;
    my @newUnitParts;
    for @units -> $u {
      my @su = @.unitParts.grep({ $_[0] eq $u }).map({ $_[1] });
      my $s = @su.elems == 1 ?? @su[0][1] !! @su.sum;
      @newUnitParts.push: ($s, $u) if $s;
    }
    @!unitParts = @newUnitParts;
    $!units = self!partsToString;
  }

  method isValid(:$fatal = False) {
    dd @.unitParts;
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
      .sort
      .map({ $_[0] ~ $[1] > 1 ?? "^{ $_[1] }" !! ''})
      .join(' ');

    my $den = @.unitParts
      .grep({ $_[1] < 0})
      .sort
      .map({ $_[0] ~ $[1] < -1 ?? "^{ $_[1].Num.abs }" !! ''})
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

# Cd ............. Celsius degrees (temperature change)
#constant s   is export = Math::Units.new( :units<s>   );
#constant m   is export = Math::Units.new( :units<m>   );
#constant g   is export = Math::Units.new( :units<g>   );
#constant deg is export = Math::Units.new( :units<deg> );
#constant A   is export = Math::Units.new( :units<A>   );
#constant C   is export = Math::Units.new( :units<C>   );
#constant Cd  is export = Math::Units.new( :units<Cd>  );

sub initialize {
  say "In init!";
  $up = Math::Units::Parser.new;

  %U<s>   = Math::Units.new( :units<s>   );
  %U<m>   = Math::Units.new( :units<m>   );
  %U<g>   = Math::Units.new( :units<g>   );
  %U<deg> = Math::Units.new( :units<deg> );
  %U<A>   = Math::Units.new( :units<A>   );
  %U<C>   = Math::Units.new( :units<C>   );
  %U<Cd>  = Math::Units.new( :units<Cd>  );

  # Add formula definitions to unit table
  for @formulas -> $fp {
    $up.addUnit: $fp.key;

    say "Adding unit { $fp.key }";
    %unitTable{$fp.key} = Math::Units.new(|%( $fp.value ));
  }
  say "Formulas";

  # Add reductions to the unit table.
  # Add reduction and its inverse to factor conversion table.
  for %reductions.kv -> $k, $v {
      $up.addUnit: $k;
      %unitTable{$k} = Math::Units.new($v);
      %factors{$k}{$v<units>} = ($v<fac> // 1) * ($v<mag> // 1);
      %factors{$v<units>}{$k} = 1 / %factors{$k}{$v<units>};
  }
  say "Reductions";

  # Check units table for validity.
  for %unitTable.kv -> $k, $v {
      .isValid(:fatal(True)) for $v.unitParts;
      die "Unit '{ $k }' was already defined during initialization!"
        if %U{$k}.defined;
      # Establish entry into quick access table if necessary.
      %U{$k} = Math::Units.new(:units($k));
  }
  say "Validity";

  # Lastly!
  $check_defs = 1;
}
