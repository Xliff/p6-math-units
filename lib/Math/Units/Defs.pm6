use v6.c;

unit module Math::Unit::Defs;

enum Magnitude is export (
  T  => 1e12,
  G  => 1e9,
  M  => 1e6,
  k  => 1e3,
  h  => 1e2,
  da => 1e1,
  d  => 1e-1,
  c  => 1e-2,
  m  => 1e-3,
  u  => 1e-6,
  µ  => 1e-6,
  n  => 1e-9,
  dn => 1e-10,
  p  => 1e-12,
  f  => 1e-15
);

# enum Units is export <
#   are l tonne N dyn Pa
#   bar barye kine  bole pond  glug
#   J W gee atm Hg  water
#   mach  coulomb V ohm siemens farad
#   Wb  henry tesla Hz  lbf tonf
#   duty  celo  jerk  slug  reyn  psi
#   tsi ouncedal  poundal tondal  hp  mil
#   s g m cycle deg rad
#   Cd  Kd  Fd  nauticalmile c
# >;

# cw: Note, in the interest of keeping things simple, we use grams (g) instead
#     of kilograms (kg). Kiograms are supported, but they will always be
#     represented as 1000 g, internally. This prevents possible conflicts
#     with the unit parser.
#
our @formulas is export = (
  are   => { :mag(h),       :units<m^2> },
  l     => { :mag(m),       :units<m^3> },
  tonne => { :mag(k * k),   :units<g> },

  N     => { :mag(k),       :units("g m/s^2") },

  Pa    => { :units<N/m^2> },

  bar   => { :mag(1e-5),    :units<Pa> },

  # cw: Restated in meters because "inches" won't be defined until later.
  mil   => { :fac(0.0254), :mag(m), :units<m> },

  dyn      => { :units("cm g/s^2") },

  barye    => { :units<dyn/cm^2> },
  kine     => { :units<cm/s> },
  bole     => { :units("g kine") },
  pond     => { :units("g gee") },
  glug     => { :units("pond s^2/cm") },
  J        => { :units("N m") },
  W        => { :units<J/s> },
  water    => { :units<pond/cm^3> },
  coulomb  => { :units("A s") },
  V        => { :units<W/A> },
  ohm      => { :units<V/A> },
  siemens  => { :units<A/V> },
  farad    => { :units<coulomb/V> },
  Wb       => { :units("V s") },
  henry    => { :units<Wb/A> },
  tesla    => { :units<Wb/m^2> },
  Hz       => { :units<cycle/s> },

  slug     => { :units("lbf s^2/ft") },
  ryn      => { :units("psi s") },
  psi      => { :units<lbf/in^2> },

  poundal  => { :units("lb ft/s^2") },

  gee          => { :fac(9.80665),   :units<m/s^2> },
  atm          => { :fac(101325),    :units<Pa> },
  Hg           => { :fac(13.5951),   :units("pond/cm^3") },
  mach         => { :fac(331.46),    :units<m/s> },
  nauticalmile => { :fac(1852),      :units<m> },
  c            => { :fac(300000000), :units<m/s>},
);

# As with the original, The base units are:
#
# m .............. meter (length) meter^2 (area) meter^3 (volume)
# g .............. gram (mass)
# s .............. second (time)
# deg ............ degree (angular measure)
# A .............. ampere (current)
# C .............. degrees Celsius (temperature)

our @reductions is export = (
  'in'  => { :fac(0.0254), :units<m> },       # inches
  'pnt' => { :fac(1/72),   :units<in> },      # PostScript points
  'ft'  => { :fac(12),     :units<in> },      # feet
  'yd'  => { :fac(3),      :units<ft> },      # yards
  'mi'  => { :fac(5280),   :units<ft> },      # miles
  'kip' => { :mag(k),      :units<lbf> },     # kilo pounds

  'barrel' => { :fac(42),   :units<gal> },    # barrels
  'gal'    => { :fac(231),  :units<in^3> },   # gallons
  'qt'     => { :fac(1/4),  :units<gal> },    # quarts
  'pt'     => { :fac(1/2),  :units<qt> },     # pints
  'gill'   => { :fac(1/4),  :units<pt> },     # gills
  'floz'   => { :fac(1/16), :units<pt> },     # fluid ounces

  'Fd'     => { :fac(1.8),  :units<Cd> },     # Farenheit degrees (change }
  'Kd'     => { :fac(1),    :units<Cd> },     # Kelvins (change }

  'min'   => { :fac(60), :units<s> },         # minutes
  'hr'    => { :fac(60), :units<min> },       # hours
  'day'   => { :fac(24), :units<hr> },        # days
  'wk'    => { :fac(7),  :units<day> },       # weeks

  'lb'  => { :fac(453.59237), :units<g> },    # pounds
  'oz'  => { :fac(1/16),      :units<lb> },   # ounces
  'dr'  => { :fac(1/16),      :units<oz> },   # drams
  'gr'  => { :fac(1/7000),    :units<lb> },   # grains
  'ton' => { :fac(2000),      :units<lb> },   # tons

  'cycle' => { :fac(360),   :units<deg> },    # complete revolution = 1 cycle
  'rad'   => { :fac(180/π), :units<deg> },    # radians
  'grad'  => { :fac(9/10),  :units<deg> },    # gradians

  'troypound'   => { :fac(5760), :units<gr> },         # troy pound
  'troyounce'   => { :fac(1/12), :units<troypound> },  # troy ounce
  'pennyweight' => { :fac(1/20), :units<troyounce> },  # penny weight

  'carat' => { :fac(0.2), :units<g> },                 # carat
);

# Formulas that we must put off due to dependencies
our @formulas2 is export = (
    tonf     => { :units("ton gee") },
    lbf      => { :units("lb gee") },
    duty     => { :units("ft lbf") },
    celo     => { :units<ft/s^2> },
    jerk     => { :units<ft/s^3> },
    ouncedal => { :units("oz ft/s^2") },
    tondal   => { :units("ton ft/s^2") },
    tsi      => { :units<tonf/in^2> },

    hp       => { :fac(550), :units("ft lbf/s") },
);

# cw: Doing it this way allows us to save an eval.
our @abbreviations is export = (
    -> $_ is rw { s:g[ « per »                ] = '/'    },
    -> $_ is rw { s:g[ « sq[uare]? \s+ (.+) » ] = "$0^2" },
    -> $_ is rw { s:g[ « cu[bic]?  \s+ (.+) » ] = "$0^3" },
    -> $_ is rw { s:g[ \s+squared »           ] = '^2'   },
    -> $_ is rw { s:g[ \s+cubed »             ] = '^3'   },

    -> $_ is rw { s:g[ « microns? »   ] = 'µ,m' },
    -> $_ is rw { s:g[ « decinano\-?  ] = 'dn,' },
    -> $_ is rw { s:g[ « tera\-?      ] = 'T,'  },
    -> $_ is rw { s:g[ « giga\-?      ] = 'G,'  },
    -> $_ is rw { s:g[ « mega\-?      ] = 'M,'  },
    -> $_ is rw { s:g[ « kilo\-?      ] = 'k,'  },
    -> $_ is rw { s:g[ « hecto\-?     ] = 'h,'  },
    -> $_ is rw { s:g[ « deka\-?      ] = 'da,' },
    -> $_ is rw { s:g[ « deca\-?      ] = 'da,' },
    -> $_ is rw { s:g[ « deci\-?      ] = 'd,'  },
    -> $_ is rw { s:g[ « centi\-?     ] = 'c,'  },
    -> $_ is rw { s:g[ « milli\-?     ] = 'm,'  },
    -> $_ is rw { s:g[ « micro\-?     ] = 'µ,'  },
    -> $_ is rw { s:g[ « nano\-?      ] = 'n,'  },
    -> $_ is rw { s:g[ « pico\-?      ] = 'p,'  },
    -> $_ is rw { s:g[ « femto\-?     ] = 'f,'  },

    -> $_ is rw { s:g[ « dn\-  ] = 'dn' },
    -> $_ is rw { s:g[ « T\-   ] = 'T'  },
    -> $_ is rw { s:g[ « G\-   ] = 'G'  },
    -> $_ is rw { s:g[ « M\-   ] = 'M'  },
    -> $_ is rw { s:g[ « k\-   ] = 'k'  },
    -> $_ is rw { s:g[ « h\-   ] = 'h'  },
    -> $_ is rw { s:g[ « da\-  ] = 'da' },
    -> $_ is rw { s:g[ « d\-   ] = 'd'  },
    -> $_ is rw { s:g[ « c\-   ] = 'c'  },
    -> $_ is rw { s:g[ « m\-   ] = 'm'  },
    -> $_ is rw { s:g[ « ต\-   ] = 'µ'  },
    -> $_ is rw { s:g[ « µ\-   ] = 'µ'  },
    -> $_ is rw { s:g[ « n\-   ] = 'n'  },
    -> $_ is rw { s:g[ « p\-   ] = 'p'  },
    -> $_ is rw { s:g[ « f\-   ] = 'f'  },

    -> $_ is rw { s:g[ « [Rr][Pp][Mm] »  ] = 'cycle\/min ' },
    -> $_ is rw { s:g[ « hz »            ] = 'Hz' },

    -> $_ is rw { s:g[ « [Cc]elsius »    ] = 'C' },
    -> $_ is rw { s:g[ « [Ff]arenheit »  ] = 'F' },
    -> $_ is rw { s:g[ « [Kk]elvins? »   ] = 'K' },
    -> $_ is rw { s:g[ « degs?\s+C »     ] = 'C' },
    -> $_ is rw { s:g[ « degs?\s+F »     ] = 'F' },
    -> $_ is rw { s:g[ « C\s+change »    ] = 'Cd' },
    -> $_ is rw { s:g[ « F\s+change »    ] = 'Fd' },
    -> $_ is rw { s:g[ « K\s+change »    ] = 'Kd' },

    -> $_ is rw { s:g[ « degs »          ] = 'deg' },
    -> $_ is rw { s:g[ « degrees? »      ] = 'deg' },
    -> $_ is rw { s:g[ « rads »          ] = 'rad' },
    -> $_ is rw { s:g[ « radians? »      ] = 'rad' },
    -> $_ is rw { s:g[ « grads »         ] = 'gra' },
    -> $_ is rw { s:g[ « gradians? »     ] = 'grad ' },

    -> $_ is rw { s:g[ « angstroms? »    ] = 'dn,m'  },
    -> $_ is rw { s:g[ « cc »            ] = 'cm^3'  },
    -> $_ is rw { s:g[ « hectares? »     ] = 'h,are' },
    -> $_ is rw { s:g[ « mils? »         ] = 'm,in'  },
    -> $_ is rw { s:g[ amperes? »        ] = 'A'     },
    -> $_ is rw { s:g[ amps? »           ] = 'A'     },
    -> $_ is rw { s:g[ days »            ] = 'day'   },
    -> $_ is rw { s:g[ drams? »          ] = 'dr'    },
    -> $_ is rw { s:g[ dynes? »          ] = 'dyn'   },
    -> $_ is rw { s:g[ feet »            ] = 'ft'    },
    -> $_ is rw { s:g[ foot »            ] = 'ft'    },
    -> $_ is rw { s:g[ gallons? »        ] = 'gal'   },
    -> $_ is rw { s:g[ gm »              ] = 'g'     },
    -> $_ is rw { s:g[ grams? »          ] = 'g'     },
    -> $_ is rw { s:g[ grains? »         ] = 'gr'    },
    -> $_ is rw { s:g[ hours? »          ] = 'hr'    },
    -> $_ is rw { s:g[ inch(es)? »       ] = 'in'    },
    -> $_ is rw { s:g[ joules? »         ] = 'J'     },
    -> $_ is rw { s:g[ lbs »             ] = 'lb'    },
    -> $_ is rw { s:g[ lbm »             ] = 'lb'    },
    -> $_ is rw { s:g[ liters? »         ] = 'l'     },
    -> $_ is rw { s:g[ meters? »         ] = 'm'     },
    -> $_ is rw { s:g[ miles? »          ] = 'mi'    },
    # cw: m,in vs (min)utes? May cause issues. Test heavily!
    # This is one of those situations where a "measure" method may help:
    # resolve the conflict:
    #   -  If length then m,in otherwise, time.
    -> $_ is rw { s:g[ minutes? »        ] = 'min'   },
    -> $_ is rw { s:g[ newtons? »        ] = 'N'     },
    -> $_ is rw { s:g[ ounces? »         ] = 'oz'    },
    -> $_ is rw { s:g[ pascals? »        ] = 'Pa'    },
    -> $_ is rw { s:g[ pints? »          ] = 'pt'    },
    -> $_ is rw { s:g[ points? »         ] = 'pnt'   },
    -> $_ is rw { s:g[ pounds? »         ] = 'lb'    },
    -> $_ is rw { s:g[ quarts? »         ] = 'q'     },
    -> $_ is rw { s:g[ seconds? »        ] = 's'     },
    -> $_ is rw { s:g[ secs? »           ] = 's'     },
    -> $_ is rw { s:g[ watts? »          ] = 'W'     },
    -> $_ is rw { s:g[ weeks? »          ] = 'wk'    },
    -> $_ is rw { s:g[ yards? »          ] = 'yd'    },
);

# Will be broken into a more useable form in initialize().
our %conversion_factors is export = (
  'in,m'   => 0.0254,
  'in,pnt' => 72,
  'ft,in'  => 12,
  'yd,ft'  => 3,
  'mi,ft'  => 5280,

  'barrel,gal' => 42,
  'gal,in^3'   => 231,
  'gal,qt'     => 4,
  'qt,pt'      => 2,
  'pt,floz'    => 16,
  'pt,gill'    => 4,

  'C,F' => sub ($_ is copy) { $_ * 1.8 + 32 },
  'F,C' => sub ($_ is copy) { ( $_ - 32 ) / 1.8 },
  'K,C' => sub ($_ is copy) { $_ - 273.15 },
  'C,K' => sub ($_ is copy) { $_ + 273.15 },

  'Cd,Fd' => 1.8,
  'Kd,Cd' => 1,

  'wk,day' => 7,
  'day,hr' => 24,
  'hr,min' => 60,
  'min,s'  => 60,

  'dollar,cent' => 100,

  'lb,g'   => 453.59237,
  'lb,oz'  => 16,
  'lb,gr'  => 7000,
  'oz,dr'  => 16,
  'ton,lb' => 2000,

  'cycle,deg' => 360,
  'rad,deg'   => 180 / π,
  'grad,deg'  => 9 / 10,

  'troypound,gr'          => 5760,
  'troypound,troyounce'   => 12,
  'troyounce,pennyweight' => 20,

  'carat,gm' => .2
);
