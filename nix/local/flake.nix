{
  description = "Local Development Environment Inputs";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.std = {
    url = "github:divnix/std";
    inputs.devshell.follows = "devshell";
  };
  outputs = id: id;
}
