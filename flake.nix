{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";

    nixos-codium = {
      url = "github:luis-hebendanz/nixos-codium";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    compdb-nix = {
      url = "github:luis-hebendanz/compdb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, compdb-nix, nixos-codium }:
    utils.lib.eachDefaultSystem (system:
      let
        appname = "vegen";
        tmpdir = "/tmp/${appname}";
        compdb = compdb-nix.packages.${system}.default;
        pkgs = import nixpkgs {
          inherit system; config = {
            allowUnfree = true;
          };
        };

        # Debug OpenGL errors with
        # $ glxinfo | grep OpenGL
        nativeDeps = with pkgs; [
          pkg-config
          bear
          cmake
          clang_12
          python3
          llvmPackages_12.bintools
          compdb
          lit
         # mycodium
        ];
        buildDeps = with pkgs; [
          llvm_12
          glibc_multi
          libxml2
        ];
      in
      rec {
        devShell = with pkgs; mkShellNoCC {
          nativeBuildInputs = nativeDeps ++ buildDeps;
          buildInputs = buildDeps ++ nativeDeps;
          shellHook = ''
            export hardeningDisable=all
            export CLANGD_FLAGS="--query-driver='/nix/store/*-clang*/bin/*'"
          '';
        };
      });
}
