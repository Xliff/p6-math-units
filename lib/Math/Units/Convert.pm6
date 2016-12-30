use v6.c;

use Math::Units::Defs;
use Math::Units::Parser;

unit module Math::Units::Convert;

# Set to 1 to emit debugging dsay:rmation.
constant DEBUG = 1;

# cw: Holds conversion factors in an easily accessed hash. First key represents "from"
#     units, second represents "to" units. The resulting value is the conversion factor,
#     or a CODE reference that performs the conversion.
my %convTable;

# cw: Defines key as a Math::Unit value of another set of measurement (preferably
#     closer to the base units, although that is not required).
our %unitTable is export;
our %factors is export;
our $up is export;

INIT { initialize(); }

sub dsay($s) is export {
  return unless DEBUG;
  say $s;
}

sub initialize {
  dsay("==== Math::Units::Convert INIT ====");

  my $up = Math::Units::Parser.new;

  for @reductions -> $r {
      dsay("[Convert] Adding reduction { $r.key }");

      %factors{$r.key}{$r.value<units>} =
        ($r.value<fac> // 1) * ($r.value<mag> // 1);
      %factors{$r.value<units>}{$r.key} = 1 / %factors{$r.key}{$r.value<units>};
  }

  # Build %convTable from %conversion factors in Math::Units::Defs
  for %conversion_factors.kv -> $k, $v {
    my ($from, $to) = do {
      $k ~~ /^ (<-[ , ]> +) ',' (.+) $/;
      $0, $1;
    }
    die "Problem parsing conversion key '$k'"
      unless $from.defined && $to.defined;
    %convTable{$from}{$to} = $v;
    dsay("Adding an entry for '$from' to '$to' to conversions table.");
    # cw: Do we remove equivalend conversions from the %factors table??
    #     (as this may prevent endless loops)
  }

  dsay("==== Math::Units::Convert ENDINIT ====");
}

sub canonicalize_unit_name($u) {
  for @abbreviations -> $a {
    # We shouldn't need REDO since replacements are global.
    &( $a )($u);
  }
  $up.parseUnits($u);
}

sub convertUnits($value, $fromU, $toU) is export {
  # Apply cannonization rules, and parse into unitParts
  my($fMag, $fParts) = canonicalize_unit_name($fromU);
  my($tMag, $tParts) = canonicalize_unit_name($toU);

  # Do tree search to see if fromU parts can be converted to toU parts.
}
