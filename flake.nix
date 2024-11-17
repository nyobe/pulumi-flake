{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs?rev=b7cde1c47b7316f6138a2b36ef6627f3d16d645c;
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    sources = builtins.fromJSON (builtins.readFile ./sources.json);
    pulumiPackage = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      source = sources.${system};
    in
      pkgs.stdenv.mkDerivation {
        pname = "pulumi";
        version = source.version;
        src = pkgs.fetchurl {
          url = source.url;
          hash = source.hash;
        };
        installPhase = "mkdir -p $out/bin && cp pulumi* $out/bin/ && $out/bin/pulumi version > $out/version.txt";
      };
  in {
    packages.x86_64-linux.default = pulumiPackage "x86_64-linux";
    packages.aarch64-linux.default = pulumiPackage "aarch64-linux";
    packages.x86_64-darwin.default = pulumiPackage "x86_64-darwin";
    packages.aarch64-darwin.default = pulumiPackage "aarch64-darwin";
  };
}
