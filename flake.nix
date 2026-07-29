{
  description = "exAthena is an open-source cross-platform MMORPG server.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      erlang = pkgs.beam28Packages.erlang;
      elixir = pkgs.beam28Packages.elixir_1_20;
      mixRelease = pkgs.beam28Packages.mixRelease.override {inherit elixir erlang;};
      expert = pkgs.beam28Packages.expert.override {inherit mixRelease;};

      libraries = with pkgs; [pkg-config];
      packages = with pkgs; [elixir erlang expert tailwindcss-language-server openssl];
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = packages;

        shellHook = ''
          export ERL_AFLAGS="-kernel shell_history enabled"
          export NODE_OPTIONS="--max-old-space-size=4096"
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
        '';
      };
    });
}
