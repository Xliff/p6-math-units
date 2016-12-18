use v6.c;

use Grammar::Tracer;

class UnitParser {
  has @.defUnits;
  has $.parser;

  grammar UnitParserGrammar {
    regex TOP { <fac> \s* <num> [ '/' <den> ]? }

    regex fac { <[+-]>? \d+ [ '.' \d+ ]? }

    regex num { [ <expr> \s* ]+ }

    regex den { <expr> }

    regex expr {
      <mag>? <unit> [ '^' $<pow> = (\d+) ]?
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
    my $m = $.parser.parse($s);
    # cw: Flesh out and use an actual expression class.
    die "Invalid units specified." unless $m.defined;
    $m;
  }
}

sub MAIN {
  my $up = UnitParser.new;
  $up.addUnit('ft');
  $up.addUnit('s');
  $up.addUnit('N');

  my $m;
  say $up.parse('1 ft/s');
  say $up.parse('1.5 Mft/ks');
  say $up.parse('-3.14159 ft/ks');
  say ($m = $up.parse('2 kN Mft^2/cs^2'));
}
