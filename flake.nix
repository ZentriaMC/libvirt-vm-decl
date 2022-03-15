{
  description = "libvirt-vm-decl";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          devShell = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.yq
              pkgs.libxml2.bin
            ];
          };
        })
    // {
      lib = {
        units = import ./units.nix;
      };
    };
}
