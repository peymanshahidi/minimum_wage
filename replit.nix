{ pkgs }: {
  deps = [
    pkgs.texliveFull
    pkgs.tzdata
    pkgs.pkg-config
    pkgs.R
    pkgs.gnumake
    pkgs.curl.dev
    pkgs.gnutls.dev
    pkgs.stdenv.cc
    pkgs.libxml2.dev
    pkgs.openssl.dev
    pkgs.nlopt
    pkgs.ghostscript
    pkgs.wget
    pkgs.python3
    pkgs.gnupg
    # R packages
    pkgs.rPackages.ggplot2
    pkgs.rPackages.dotenv
    pkgs.rPackages.cowplot
    pkgs.rPackages.data_table
    pkgs.rPackages.directlabels
    pkgs.rPackages.dplyr
    pkgs.rPackages.ggrepel
    pkgs.rPackages.gridExtra
    pkgs.rPackages.gt
    pkgs.rPackages.lfe
    pkgs.rPackages.lmtest
    pkgs.rPackages.lubridate
    pkgs.rPackages.magrittr
    pkgs.rPackages.plyr
    pkgs.rPackages.purrr
    pkgs.rPackages.quantreg
    pkgs.rPackages.sandwich
    pkgs.rPackages.scales
    pkgs.rPackages.stargazer
    pkgs.rPackages.tidyr
    pkgs.rPackages.remotes
  ];
  env = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };
}