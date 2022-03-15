let
  flake = builtins.getFlake (toString ./.);
  system = builtins.currentSystem;
  pkgs = flake.inputs.nixpkgs.legacyPackages.${system};
  decl = pkgs.callPackage ./vm-xml.nix { };

  inherit (import ./units.nix) KiB MiB GiB TiB;
in
map decl [
  {
    name = "github-worker-0";
    memory = GiB 1; # 1073740000;
    nic = "virtbr0";
    mac = "1e:08:53:d2:29:cd";
  }
  {
    name = "github-worker-1";
    memory = GiB 2;
    nic = "virtbr0";
    mac = "1e:08:53:d2:29:ce";
  }
]
