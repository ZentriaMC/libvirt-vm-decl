let
  flake = builtins.getFlake (toString ./.);
  system = builtins.currentSystem;
  pkgs = flake.inputs.nixpkgs.legacyPackages.${system};

  decl = pkgs.callPackage ./vm-xml.nix { };
in

decl {
  name = "github-worker-0";
  memory = 1073740000;
  nic = "virtbr0";
  mac = "1e:08:53:d2:29:cd";
}
