use v6.c;

use Math::Units::Defs;

#use Grammar::Tracer;

class Math::Units::Parser {
  has %.defUnits;
  has $.parser;

  grammar UnitParserGrammar {
    regex TOP { <fac> \s* <units> }

    regex fac { <[+-]>? \d+ [ '.' \d+ ]? }

    regex units { <num> [ '/' <den> ]? }

    regex num { [ <expr> \s* ]+ }

    regex den { <expr> }

    regex expr {
      <mag>? <unit> [ [ '^' || '**' ] $<pow> = (\d+) ]?
    }

    token mag {
      [ T || G || M || k || h || da || d || c || m || u || µ || n || dn || p || f ]
      ','?
    }

    proto regex unit { * }
  }


  submethod BUILD {
    $!parser = UnitParserGrammar.new;
  }

  method addUnit(Str $unit) {
    return if %.defUnits{$unit}.defined;

    $.parser.^add_multi_method("unit:sym<$unit>", my regex { $unit });
    $.parser.^compose;
    %.defUnits{$unit} = 1
  }

  method parse($s) {
    my $m = $.parser.parse($s);
    my ($mag, $unitParts) = self!handleUnitData($m<units>);

    (
      fac   =>     $m<fac>.Num,
      mag   =>     $mag,
      units =>     $m<units>.Str,
      unitParts => $unitParts.list
    );
  }

  method parseUnits(Str $u) {
    my $m = $.parser.subparse($u, :rule('units'));
    die "Could not parse units" unless $.defined && $m ~~ Match;
    self!handleUnitData($m)
  }

  method !handleUnitData(Match $m) {
    my $mag = 1;
    my $unitParts = [];

    for $m<num><expr> -> $ne {
      my $pow = $ne<pow>.defined ?? $ne<pow>.Str.Int !! 1;
      $unitParts.push: [ $ne<unit>.Str, $pow; ];
      $mag *= Magnitude.enums{$ne<mag>.Str} if $ne<mag>.defined;
    }
    if $m<den>.defined {
      $unitParts.push: [
        $m<den><expr><unit>.Str,
        ($m<den><expr><pow>.defined ?? $m<den><expr><pow>.Str.Int !! 1) * -1
      ];
      $mag /= Magnitude.enms{$m<den><expr><mag>}
        if $<den><expr><mag>.defined;
    }

    $mag, $unitParts;
  }
}
