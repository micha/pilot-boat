use Text::CSV::Simple;
use Math::Units qw(convert);

{
  my @d;

  sub load_csv() {
    my $f = $_[0];
    my $p = Text::CSV::Simple->new;
    @d = $p->read_file($f);
    die &err("can't read file '$f': $!") unless @d;
  }

  sub c() {
    $_[0] =~ /^([a-zA-Z])([a-zA-Z])?([0-9]+)$/;
    my $c1 = ord(uc($1))-ord('A')+1;
    my $c2 = ord(uc($2))-ord('A')+1;
    my $c = ($2 ? $c1*(ord('Z')-ord('A')+1)+$c2-1 : $c1-1);
    my $r = $3-1;
    return $d[$r][$c];
  }

  { # HYDROSTATICS

    &load_csv("data/Hydrostatics & Stability Report.csv");

    &c("b34");
    my $t = $wb{hydrostatics} = {};  

    # overall dimensions
    $t->{name}    = &c("A1");
    $t->{LOA}     = &p3(convert(&c("H45"), &c("M45"), "m"));
    $t->{BOA}     = &p3(convert(&c("H46"), &c("M46"), "m"));
    $t->{D}       = &p3(convert(&c("H47"), &c("M47"), "m"));

    # waterline dimensions
    $t->{LWL}     = &p3(convert(&c("H52"), &c("M52"), "m"));
    $t->{BWL}     = &p3(convert(&c("H53"), &c("M53"), "m"));
    $t->{T}       = &p3(convert(&c("H54"), &c("M54"), "m"));

    # volumetric values
    $t->{displ}   = &p0(convert(&c("H59"), &c("M59"), "kgf"));
    $t->{vol}     = &p3(convert(&c("H60"), &c("M60"), "m^3"));
    $t->{LCB}     = &p3(convert(&c("H61"), &c("M61"), "m"));
    $t->{TCB}     = &p3(convert(&c("H62"), &c("M62"), "m"));
    $t->{VCB}     = &p3(convert(&c("H63"), &c("M63"), "m"));
    $t->{Aws}     = &p3(convert(&c("H64"), &c("M64"), "m^2"));
    $t->{MTC}     = &p3(convert(&c("H65"), &c("M65"), "kgf-m/cm"));

    # waterplane values
    $t->{Awp}     = &p3(convert(&c("H70"), &c("M70"), "m^2"));
    $t->{LCF}     = &p3(convert(&c("H71"), &c("M71"), "m"));
    $t->{TCF}     = &p3(convert(&c("H72"), &c("M72"), "m"));
    $t->{TPC}     = &p3(convert(&c("H73"), &c("M73"), "kgf/cm"));

    # sectional parameters
    $t->{Ax}      = &p3(convert(&c("H78"), &c("M78"), "m^2"));
    $t->{Ax_loc}  = &p3(convert(&c("H79"), &c("M79"), "m"));

    # hull form coefficients
    $t->{Cb}      = &p3(&c("F84"));
    $t->{Cp}      = &p3(&c("F85"));
    $t->{Cvp}     = &p3(&c("F86"));
    $t->{Cx}      = &p3(&c("W84"));
    $t->{Cwp}     = &p3(&c("W85"));
    $t->{Cws}     = &p3(&c("W86"));

    # static stability parameters
    $t->{It}      = &p3(convert(&c("F91"), &c("L91"), "m^4"));
    $t->{BMt}     = &p3(convert(&c("F92"), &c("L92"), "m"));
    $t->{GMt}     = &p3(convert(&c("F93"), &c("L93"), "m"));
    $t->{Il}      = &p3(convert(&c("W91"), &c("AB91"), "m^4"));
    $t->{BMl}     = &p3(convert(&c("W92"), &c("AB92"), "m"));
    $t->{GMl}     = &p3(convert(&c("W93"), &c("AB93"), "m"));

    # projected chine area values
    $t->{Ap}      = &p3(28.12);   # m2
    $t->{lp}      = &p3(10.455);  # m
    $t->{CAp}     = &p3(5.4);     # m
  }

  { # CONSTANTS
    my $t = $wb{const} = {};  

    $t->{SGfo} = .9;
    $t->{SGgw} = 1;
    $t->{SGbw} = 1;
  }

  { # REQUIREMENTS
    my $t = $wb{requirements} = {};  

    my %drive = (
      "four conventional shafts"  => 1.4,
      "two conventional shafts"   => 1.5,
      "standard stern drives"     => 1.6,
      "racing stern drives"       => 1.8
    );


    $t->{Vs_max}    = 30;   # kt
    $t->{Vs_cru}    = 25;   # kt
    $t->{range}     = 300;  # nm
    $t->{reserve}   = .2;   # %
    $t->{endur}     = 2;    # days
    $t->{fw}        = 20;   # gal
    $t->{trialsfo}  = 100;  # gal
    $t->{barnaby_k} = $drive{"two conventional shafts"};  # gal
    $t->{fuel_cons} = .05;  # gal/hp/hr
    $t->{qun}       = 10;   # gal

    $t->{load} = {
      trials => {
        name  => "trials",
        symb  => "\\Zwtr",
        pax   => 2,   # ppl
        fo    => 0,   # %
        fw    => 0,   # %
        bw    => 0,   # %
        gw    => 0,   # %
        items => [
          [ "Misc. safety gear" => 50 ]
        ]
      },
      range => {
        name  => "\\sfrac{3}{4} load",
        symb  => "\\Zwc",
        pax   => 3,   # ppl
        fo    => 1,   # %
        fw    => .75, # %
        bw    => .25, # %
        gw    => .25, # %
        items => [
          [ "Personal gear"     , 4 * 10 ],
          [ "Food"              , .75 * 5 * 4 * 4 ],
          [ "Misc. safety gear" , 50 ]
        ]
      },
      full => {
        name  => "full-load",
        symb  => "\\Zwf",
        pax   => 4,   # ppl
        fo    => 1,   # %
        fw    => 1,   # %
        bw    => 0,   # %
        gw    => 0,   # %
        items => [
          [ "Personal gear"     , 4 * 10 ],
          [ "Food"              , .75 * 5 * 4 * 4 ],
          [ "Misc. safety gear" , 50 ]
        ]
      }
    };
  }

  { # TANKS
    my $t = $wb{tanks} = {};  

    $t->{fw}  = $wb{requirements}{fw};
    $t->{gw}  = 0;
    $t->{bw}  = 0;
    $t->{fo}  = 0;
  }
  
}
