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

        mycodium = import ./vscode.nix {
          vscode = nixos-codium.packages.${system}.default;
          inherit pkgs;
          vscodeBaseDir = tmpdir + "/codium";
          env = {
            #HOME = tmpdir;
            LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.libepoxy}/lib";
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
          compdb
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
          hardeningDisable = [ "all" ];
          shellHook = ''
          '';
        };
      });
}
