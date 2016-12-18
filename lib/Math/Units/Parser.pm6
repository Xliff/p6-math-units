use v6.c;

# cw: Doing it this way allows us to save an eval.
my @abbreviations = (
    -> $_ is copy { s[ « per »        ] = '/'   },
    -> $_ is copy { s[ « sq[uare]?\s  ] = 'sq,' },
    -> $_ is copy { s[ « cu[bic]?\s+  ] = 'cu,' },
    -> $_ is copy { s[ \s+squared »   ] = '^2'  },
    -> $_ is copy { s[ \s+cubed »     ] = '^3'  },

    -> $_ is copy { s[ « microns? »   ] = 'µ,m' },
    -> $_ is copy { s[ « decinano-?   ] = 'dn,' },
    -> $_ is copy { s[ « tera-?       ] = 'T,'  },
    -> $_ is copy { s[ « giga-?       ] = 'G,'  },
    -> $_ is copy { s[ « mega-?       ] = 'M,'  },
    -> $_ is copy { s[ « kilo-?       ] = 'k,'  },
    -> $_ is copy { s[ « hecto-?      ] = 'h,'  },
    -> $_ is copy { s[ « deka-?       ] = 'da,' },
    -> $_ is copy { s[ « deca-?       ] = 'da,' },
    -> $_ is copy { s[ « deci-?       ] = 'd,'  },
    -> $_ is copy { s[ « centi-?      ] = 'c,'  },
    -> $_ is copy { s[ « milli-?      ] = 'm,'  },
    -> $_ is copy { s[ « micro-?      ] = 'µ,'  },
    -> $_ is copy { s[ « nano-?       ] = 'n,'  },
    -> $_ is copy { s[ « pico-?       ] = 'p,'  },
    -> $_ is copy { s[ « femto-?      ] = 'f,'  },

    -> $_ is copy { s[ « dn-  ] = 'dn' },
    -> $_ is copy { s[ « T-   ] = 'T'  },
    -> $_ is copy { s[ « G-   ] = 'G'  },
    -> $_ is copy { s[ « M-   ] = 'M'  },
    -> $_ is copy { s[ « k-   ] = 'k'  },
    -> $_ is copy { s[ « h-   ] = 'h'  },
    -> $_ is copy { s[ « da-  ] = 'da' },
    -> $_ is copy { s[ « da-  ] = 'da' },
    -> $_ is copy { s[ « d-   ] = 'd'  },
    -> $_ is copy { s[ « c-   ] = 'c'  },
    -> $_ is copy { s[ « m-   ] = 'm'  },
    -> $_ is copy { s[ « ต-   ] = 'µ'  },
    -> $_ is copy { s[ « µ-   ] = 'µ'  },
    -> $_ is copy { s[ « n-   ] = 'n'  },
    -> $_ is copy { s[ « p-   ] = 'p'  },
    -> $_ is copy { s[ « f-   ] = 'f'  },

    -> $_ is copy { s[ « [Rr][Pp][Mm] »  ] = 'cycle\/min ' },
    -> $_ is copy { s[ « hz »            ] = 'Hz' },

    -> $_ is copy { s[ « [Cc]elsius »    ] = 'C' },
    -> $_ is copy { s[ « [Ff]arenheit »  ] = 'F' },
    -> $_ is copy { s[ « [Kk]elvins? »   ] = 'K' },
    -> $_ is copy { s[ « degs?\s+C »     ] = 'C' },
    -> $_ is copy { s[ « degs?\s+F »     ] = 'F' },
    -> $_ is copy { s[ « C\s+change »    ] = 'Cd' },
    -> $_ is copy { s[ « F\s+change »    ] = 'Fd' },
    -> $_ is copy { s[ « K\s+change »    ] = 'Kd' },

    -> $_ is copy { s[ « degs »          ] = 'deg' },
    -> $_ is copy { s[ « degrees? »      ] = 'deg' },
    -> $_ is copy { s[ « rads »          ] = 'rad' },
    -> $_ is copy { s[ « radians? »      ] = 'rad' },
    -> $_ is copy { s[ « grads »         ] = 'gra' },
    -> $_ is copy { s[ « gradians? »     ] = 'grad ' },

    -> $_ is copy { s[ « angstroms? »    ] = 'dn,m'  },
    -> $_ is copy { s[ « cc »            ] = 'cm^3'  },
    -> $_ is copy { s[ « hectares? »     ] = 'h,are' },
    -> $_ is copy { s[ « mils? »         ] = 'm,in'  },
    -> $_ is copy { s[ amperes? »        ] = 'A'     },
    -> $_ is copy { s[ amps? »           ] = 'A'     },
    -> $_ is copy { s[ days »            ] = 'day'   },
    -> $_ is copy { s[ drams? »          ] = 'dr'    },
    -> $_ is copy { s[ dynes? »          ] = 'dyn'   },
    -> $_ is copy { s[ feet »            ] = 'ft'    },
    -> $_ is copy { s[ foot »            ] = 'ft'    },
    -> $_ is copy { s[ gallons? »        ] = 'gal'   },
    -> $_ is copy { s[ gm »              ] = 'g'     },
    -> $_ is copy { s[ grams? »          ] = 'g'     },
    -> $_ is copy { s[ grains? »         ] = 'gr'    },
    -> $_ is copy { s[ hours? »          ] = 'hr'    },
    -> $_ is copy { s[ inch(es)? »       ] = 'in'    },
    -> $_ is copy { s[ joules? »         ] = 'J'     },
    -> $_ is copy { s[ lbs »             ] = 'lb'    },
    -> $_ is copy { s[ lbm »             ] = 'lb'    },
    -> $_ is copy { s[ liters? »         ] = 'l'     },
    -> $_ is copy { s[ meters? »         ] = 'm'     },
    -> $_ is copy { s[ miles? »          ] = 'mi'    },
    # cw: m,in vs (min)utes? May cause issues. Test heavily!
    # This is one of those situations where a "measure" method may help:
    # resolve the conflict:
    #   -  If length then m,in otherwise, time.
    -> $_ is copy { s[ minutes? »        ] = 'min'   },
    -> $_ is copy { s[ newtons? »        ] = 'N'     },
    -> $_ is copy { s[ ounces? »         ] = 'oz'    },
    -> $_ is copy { s[ pascals? »        ] = 'Pa'    },
    -> $_ is copy { s[ pints? »          ] = 'pt'    },
    -> $_ is copy { s[ points? »         ] = 'pnt'   },
    -> $_ is copy { s[ pounds? »         ] = 'lb'    },
    -> $_ is copy { s[ quarts? »         ] = 'q'     },
    -> $_ is copy { s[ seconds? »        ] = 's'     },
    -> $_ is copy { s[ secs? »           ] = 's'     },
    -> $_ is copy { s[ watts? »          ] = 'W'     },
    -> $_ is copy { s[ weeks? »          ] = 'wk'    },
    -> $_ is copy { s[ yards? »          ] = 'yd'    },
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
    my $unitParts;
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

    $mag, @unitParts;
  }
}
