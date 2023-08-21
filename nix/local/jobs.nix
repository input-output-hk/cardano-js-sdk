/*
This file holds a variety of scriptable repository tasks.
*/
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
in {
  config-update = nixpkgs.writeShellApplication {
    name = "config-update";
    runtimeInputs = with nixpkgs; [git git-subrepo];
    text = ''
      git subrepo pull packages/cardano-services/config --message='chore: git subrepo pull packages/cardano-services/config' "$@"
    '';
  };
}
