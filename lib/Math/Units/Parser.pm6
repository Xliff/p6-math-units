use v6.c;

use Math::Units::Defs;

# cw: Doing it this way allows us to save an eval.
my @abbreviations = (
    -> $_ is rw { s[ « per »        ] = '/'   },
    #-> $_ is rw { s[ « sq[uare]?\s+ ] = 'sq,' },
    -> $_ is rw { s[ « sq[uare]?+ ] = 'sq,' },

    #-> $_ is rw { s[ « cu[bic]?\s+  ] = 'cu,' },
    -> $_ is rw { s[ « cu[bic]?+  ] = 'cu,' },
    -> $_ is rw { s[ \s+squared »   ] = '^2'  },
    -> $_ is rw { s[ \s+cubed »     ] = '^3'  },

    -> $_ is rw { s[ « microns? »   ] = 'µ,m' },
    -> $_ is rw { s[ « decinano\-   ] = 'dn,' },
    -> $_ is rw { s[ « tera\-?      ] = 'T,'  },
    -> $_ is rw { s[ « giga\-?      ] = 'G,'  },
    -> $_ is rw { s[ « mega\-?      ] = 'M,'  },
    -> $_ is rw { s[ « kilo\-?      ] = 'k,'  },
    -> $_ is rw { s[ « hecto\-?     ] = 'h,'  },
    -> $_ is rw { s[ « deka\-?      ] = 'da,' },
    -> $_ is rw { s[ « deca\-?      ] = 'da,' },
    -> $_ is rw { s[ « deci\-?      ] = 'd,'  },
    -> $_ is rw { s[ « centi\-?     ] = 'c,'  },
    -> $_ is rw { s[ « milli\-?     ] = 'm,'  },
    -> $_ is rw { s[ « micro\-?     ] = 'µ,'  },
    -> $_ is rw { s[ « nano\-?      ] = 'n,'  },
    -> $_ is rw { s[ « pico\-?      ] = 'p,'  },
    -> $_ is rw { s[ « femto\-?     ] = 'f,'  },

    -> $_ is rw { s[ « dn\-  ] = 'dn' },
    -> $_ is rw { s[ « T\-   ] = 'T'  },
    -> $_ is rw { s[ « G\-   ] = 'G'  },
    -> $_ is rw { s[ « M\-   ] = 'M'  },
    -> $_ is rw { s[ « k\-   ] = 'k'  },
    -> $_ is rw { s[ « h\-   ] = 'h'  },
    -> $_ is rw { s[ « da\-  ] = 'da' },
    -> $_ is rw { s[ « d\-   ] = 'd'  },
    -> $_ is rw { s[ « c\-   ] = 'c'  },
    -> $_ is rw { s[ « m\-   ] = 'm'  },
    -> $_ is rw { s[ « ต\-   ] = 'µ'  },
    -> $_ is rw { s[ « µ\-   ] = 'µ'  },
    -> $_ is rw { s[ « n\-   ] = 'n'  },
    -> $_ is rw { s[ « p\-   ] = 'p'  },
    -> $_ is rw { s[ « f\-   ] = 'f'  },

    -> $_ is rw { s[ « [Rr][Pp][Mm] »  ] = 'cycle\/min ' },
    -> $_ is rw { s[ « hz »            ] = 'Hz' },

    -> $_ is rw { s[ « [Cc]elsius »    ] = 'C' },
    -> $_ is rw { s[ « [Ff]arenheit »  ] = 'F' },
    -> $_ is rw { s[ « [Kk]elvins? »   ] = 'K' },
    -> $_ is rw { s[ « degs?\s+C »     ] = 'C' },
    -> $_ is rw { s[ « degs?\s+F »     ] = 'F' },
    -> $_ is rw { s[ « C\s+change »    ] = 'Cd' },
    -> $_ is rw { s[ « F\s+change »    ] = 'Fd' },
    -> $_ is rw { s[ « K\s+change »    ] = 'Kd' },

    -> $_ is rw { s[ « degs »          ] = 'deg' },
    -> $_ is rw { s[ « degrees? »      ] = 'deg' },
    -> $_ is rw { s[ « rads »          ] = 'rad' },
    -> $_ is rw { s[ « radians? »      ] = 'rad' },
    -> $_ is rw { s[ « grads »         ] = 'gra' },
    -> $_ is rw { s[ « gradians? »     ] = 'grad ' },

    -> $_ is rw { s[ « angstroms? »    ] = 'dn,m'  },
    -> $_ is rw { s[ « cc »            ] = 'cm^3'  },
    -> $_ is rw { s[ « hectares? »     ] = 'h,are' },
    -> $_ is rw { s[ « mils? »         ] = 'm,in'  },
    -> $_ is rw { s[ amperes? »        ] = 'A'     },
    -> $_ is rw { s[ amps? »           ] = 'A'     },
    -> $_ is rw { s[ days »            ] = 'day'   },
    -> $_ is rw { s[ drams? »          ] = 'dr'    },
    -> $_ is rw { s[ dynes? »          ] = 'dyn'   },
    -> $_ is rw { s[ feet »            ] = 'ft'    },
    -> $_ is rw { s[ foot »            ] = 'ft'    },
    -> $_ is rw { s[ gallons? »        ] = 'gal'   },
    -> $_ is rw { s[ gm »              ] = 'g'     },
    -> $_ is rw { s[ grams? »          ] = 'g'     },
    -> $_ is rw { s[ grains? »         ] = 'gr'    },
    -> $_ is rw { s[ hours? »          ] = 'hr'    },
    -> $_ is rw { s[ inch(es)? »       ] = 'in'    },
    -> $_ is rw { s[ joules? »         ] = 'J'     },
    -> $_ is rw { s[ lbs »             ] = 'lb'    },
    -> $_ is rw { s[ lbm »             ] = 'lb'    },
    -> $_ is rw { s[ liters? »         ] = 'l'     },
    -> $_ is rw { s[ meters? »         ] = 'm'     },
    -> $_ is rw { s[ miles? »          ] = 'mi'    },
    # cw: m,in vs (min)utes? May cause issues. Test heavily!
    # This is one of those situations where a "measure" method may help:
    # resolve the conflict:
    #   -  If length then m,in otherwise, time.
    -> $_ is rw { s[ minutes? »        ] = 'min'   },
    -> $_ is rw { s[ newtons? »        ] = 'N'     },
    -> $_ is rw { s[ ounces? »         ] = 'oz'    },
    -> $_ is rw { s[ pascals? »        ] = 'Pa'    },
    -> $_ is rw { s[ pints? »          ] = 'pt'    },
    -> $_ is rw { s[ points? »         ] = 'pnt'   },
    -> $_ is rw { s[ pounds? »         ] = 'lb'    },
    -> $_ is rw { s[ quarts? »         ] = 'q'     },
    -> $_ is rw { s[ seconds? »        ] = 's'     },
    -> $_ is rw { s[ secs? »           ] = 's'     },
    -> $_ is rw { s[ watts? »          ] = 'W'     },
    -> $_ is rw { s[ weeks? »          ] = 'wk'    },
    -> $_ is rw { s[ yards? »          ] = 'yd'    },
);

class Math::Units { ... }

class Math::Units::Parser {
  has @.defUnits;
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
    my $m = $.parser.parse($s);
    my ($mag, $unitParts) = self!handleUnitData($m<units>);

    Math::Units.new(
      :fac($m<fac>.Num),
      :$mag,
      :units($m<units>.Str),
      :unitParts($unitParts.list)
    );
  }

  method parseUnits(Str $u) {
    my $m = $.parser.subparse($u, :rule('units'));
    die "Could not parse units" unless $m;
    self!handleUnitData($m)
  }

  method !handleUnitData(Match $m) {
    my $mag;
    my $unitParts = [];

    for $m<units><num><expr> -> $ne {
      $unitParts.push: [ $_<unit>, $_<pow> ];
      $mag *= Magnitude($ne<mag>).Int if $ne<mag>.defined;
    }
    $unitParts.push: [
      $m<units><den><expr><unit>,
      $m<units><den><expr><pow>.Num * -1
    ];
    $mag /= Magnitude($m<units><den><expr><mag>).Int
      if $<units><den><expr><mag>.defined;

    $mag, $unitParts;
  }
}
