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
  tesla    => { :units<Wb/m^s> },
  Hz       => { :units<cycle/s> },
  lbf      => { :units("lb gee") },
  tonf     => { :units("ton gee") },
  duty     => { :units("ft lbf") },
  celo     => { :units<ft/s^2> },
  jerk     => { :units<ft/s^3> },
  slug     => { :units("lbf s^2/ft") },
  ryn      => { :units("psi s") },
  psi      => { :units<lbf/in^2> },
  tsi      => { :units<tonf/in^2> },
  ouncedal => { :units("oz ft/s^2") },
  poundal  => { :units("lb ft/s^2") },
  tondal   => { :units("ton ft/s^2") },

  gee          => { :fac(9.80665),   :units<m/s^2> },
  atm          => { :fac(101325),    :units<Pa> },
  Hg           => { :fac(13.5951),   :units("pond/cm^3") },
  mach         => { :fac(331.46),    :units<m/s> },
  hp           => { :fac(550),       :units("ft lbf/s") },
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
