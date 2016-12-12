use v6.c;

use Grammar::Tracer;

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

  # method refresh {
  #   @!defUnits = Units.enum.keys, %formulas.keys;
  # }

  method parse($s) {
    #self.refresh;
    $.parser.parse($s);
  }
}

sub MAIN {
  my $up = UnitParser.new;
  $up.addUnit('ft');
  $up.addUnit('s');

  say $up.parse('ft/s');
  say $up.parse('Mft/ks');
  say $up.parse('ft/ks');
}
