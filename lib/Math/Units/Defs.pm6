use v6.c;

unit module Math::Unit::Defs;

enum Magnitude is export (
  'T'  => 1e12,
  'G'  => 1e9,
  'M'  => 1e6,
  'k'  => 1000,
  'h'  => 100,
  'da' => 10,
  'd'  => .1,
  'c'  => .01,
  'm'  => .001,
  'u'  => 1e-6,
  'µ'  => 1e-6,
  'n'  => 1e-9,
  'dn' => 1e-10,
  'p'  => 1e-12,
  'f'  => 1e-15
);

enum Units is export <
  are l tonne N dyn Pa
  bar barye kine  bole pond  glug
  J W gee atm Hg  water
  mach  coulomb V ohm siemens farad
  Wb  henry tesla Hz  lbf tonf
  duty  celo  jerk  slug  reyn  psi
  tsi ouncedal  poundal tondal  hp  mil
  s g m cycle deg rad
  Cd  Kd  Fd  nauticalmile
>;

class Math::Units { ... }

# cw: Note, in the interest of keeping things simple, we use grams (g) instead
#     of kilograms (kg). Kiograms are supported, but they will always be
#     represented as 1000 g, internally. This prevents possible conflicts
#     with the unit parser.
my %formulas is export = (
  are   => Math::Units.new(:mag(h),    :units<m/s>),
  l     => Math::Units.new(:mag(m),    :units<m^3>),
  tonne => Math::Units.new(:mag(k*k),  :units<g>),
  bar   => Math::Units.new(:mag(1e-5), :units<Pa>),
  mil   => Math::Units.new(:mag<m>,    :units<in>),
  N     => Math::Units.new(:mag<k>,    :units<g m/s^2>),

  dyn      => Math::Units.new(:units<cm g/s^2>),
  Pa       => Math::Units.new(:units<N/m^2>),
  barye    => Math::Units.new(:units<dyn/cm^2>),
  kine     => Math::Units.new(:units<cm/s>),
  bole     => Math::Units.new(:units<g kine>),
  pond     => Math::Units.new(:units<g gee>),
  glug     => Math::Units.new(:units<pond s^2/cm>),
  J        => Math::Units.new(:units<N m>),
  W        => Math::Units.new(:units<J/s>),
  water    => Math::Units.new(:units<pond/cm^3>),
  coulomb  => Math::Units.new(:units<A s>),
  V        => Math::Units.new(:units<W/A>),
  ohm      => Math::Units.new(:units<V/A>),
  siemens  => Math::Units.new(:units<A/V>),
  farad    => Math::Units.new(:units<coulomb/V>),
  Wb       => Math::Units.new(:units<V s>),
  henry    => Math::Units.new(:units<Wb/A>),
  tesla    => Math::Units.new(:units<Wb/m^s>),
  Hz       => Math::Units.new(:units<cycle/s>),
  lbf      => Math::Units.new(:units<lb gee>),
  tonf     => Math::Units.new(:units<ton gee>),
  duty     => Math::Units.new(:units<ft lbf>),
  celo     => Math::Units.new(:units<ft/s^2>),
  jerk     => Math::Units.new(:units<ft/s^3>),
  slug     => Math::Units.new(:units<lbf s^2/ft>),
  ryn      => Math::Units.new(:units<psi s>),
  psi      => Math::Units.new(:units<lbf/in^2>),
  tsi      => Math::Units.new(:units<tonf/in^2>),
  ouncedal => Math::Units.new(:units<oz ft/s^2>),
  poundal  => Math::Units.new(:units<lb ft/s^2>),
  tondal   => Math::Units.new(:units<ton ft/s^2>),

  gee          => Math::Units.new(:fac(9.80665), :units<m/s^2>),
  atm          => Math::Units.new(:fac(101325),  :units<Pa>),
  Hg           => Math::Units.new(:fac(13.5951), :units<pond/cm^3>),
  mach         => Math::Units.new(:fac(331.46),  :units<m/s>)
  hp           => Math::Units.new(:fac(550),     :units<ft lbf/s>),
  nauticalmile => Math::Units.new(:fac(1852),    :units<m>),
);

# As with the original, The base units are:
#
# m .............. meter (length) meter^2 (area) meter^3 (volume)
# g .............. gram (mass)
# s .............. second (time)
# deg ............ degree (angular measure)
# A .............. ampere (current)
# C .............. degrees Celsius (temperature)
# Cd ............. Celsius degrees (temperature change)
constant s   is export = Math::Units.new(:units<s>);
constant m   is export = Math::Units.new(:units<m>);
constant g   is export = Math::Units.new(:units<g>);
constant deg is export = Math::Units.new(:units<deg>);
constant A   is export = Math::Units.new(:units<A>);
constant C   is export = Math::Units.new(:units<C>);
constant Cd  is export = Math::Units.new(:units<Cd>);


my %reductions is export = (
  'in'  => Math::Units.new(:fac(0.0254), :units<m>),       # inches
  'pnt' => Math::Units.new(:fac(1/72),   :units<in>),      # PostScript points
  'ft'  => Math::Units.new(:fac(12),     :units<in>),      # feet
  'yd'  => Math::Units.new(:fac(3),      :units<ft>),      # yards
  'mi'  => Math::Units.new(:fac(5280),   :units<ft>),      # miles
  'kip' => Math::Units.new(:mag<k>,      :units<lbf>),     # kilo pounds

  'barrel' => Math::Units.new(:fac(42),   :units<gal>),    # barrels
  'gal'    => Math::Units.new(:fac(231),  :units<in^3>),   # gallons
  'qt'     => Math::Units.new(:fac(1/4),  :units<gal>),    # quarts
  'pt'     => Math::Units.new(:fac(1/2),  :units<qt>),     # pints
  'gill'   => Math::Units.new(:fac(1/4),  :units<pt>),     # gills
  'floz'   => Math::Units.new(:fac(1/16), :units<pt>),     # fluid ounces

  'Fd'     => Math::Units.new(:fac(1.8),  :units<Cd>),     # Farenheit degrees (change)
  'Kd'     => Math::Units.new(:fac(1),    :units<Cd>),     # Kelvins (change)

  'min'   => Math::Units.new(:fac(60), :units<s>),         # minutes
  'hr'    => Math::Units.new(:fac(60), :units<min>),       # hours
  'day'   => Math::Units.new(:fac(24), :units<hr>),        # days
  'wk'    => Math::Units.new(:fac(7),  :units<day>),       # weeks

  'lb'  => Math::Units.new(:fac(453.59237), :units<g>),    # pounds
  'oz'  => Math::Units.new(:fac(1/16),      :units<lb>),   # ounces
  'dr'  => Math::Units.new(:fac(1/16),      :units<oz>),   # drams
  'gr'  => Math::Units.new(:fac(1/7000),    :units<lb>),   # grains
  'ton' => Math::Units.new(:fac(2000),      :units<lb>),   # tons

  'cycle' => Math::Units.new(:fac(360),   :units<deg>),    # complete revolution = 1 cycle
  'rad'   => Math::Units.new(:fac(180/π), :units<deg>),    # radians
  'grad'  => Math::Units.new(:fac(9/10),  :units<deg>),    # gradians

  'troypound'   => Math::Units.new(:fac(5760), :units<gr>),         # troy pound
  'troyounce'   => Math::Units.new(:fac(1/12), :units<troypound>),  # troy ounce
  'pennyweight' => Math::Units.new(:fac(1/20), :units<troyounce>),  # penny weight

  'carat' => Math::Units.new(:fac(0.2), :units<gm>),                # carat
);
