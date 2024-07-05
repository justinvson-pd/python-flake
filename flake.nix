{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          pythonPackages = pkgs.python311Packages;

          venvDir = "./env";

          runPackages = with pkgs; [
            pythonPackages.python
            pythonPackages.venvShellHook
          ];

          devPackages = with pkgs; runPackages ++ [
            pythonPackages.pylint
            pythonPackages.flake8
            pythonPackages.black 
          ];

          postHook = ''
            PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
          '';
        in
        with pkgs;
        {
          devShells.default = mkShell {
            inherit venvDir;
            buildInputs = [ devPackages ];
            postShellHook = postHook;
          };
        }
      );
}
