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
      elixir = pkgs.beam.packages.erlang_28.elixir_1_20;

      libraries = with pkgs; [pkg-config];
      packages = with pkgs; [elixir erlang openssl];
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = packages;

        shellHook = ''
          export MIX_HOME=$PWD/.nix-mix
          export HEX_HOME=$PWD/.nix-hex
          export ERL_AFLAGS="-kernel shell_history enabled"
          export NODE_OPTIONS="--max-old-space-size=4096"
          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
        '';
      };
    });
}
