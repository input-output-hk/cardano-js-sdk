{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
  };

  outputs = {
    self,
    dream2nix,
    nixpkgs,
  } @ inp: let
    inherit (nixpkgs.legacyPackages.x86_64-linux) pkgs;
    inherit (nixpkgs) lib;
  in
    (dream2nix.lib.makeFlakeOutputs {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
      config.packagesDir = "./locks";
      source = ./.;
      settings = [
        {subsystemInfo.noDev = false;}
      ];
      packageOverrides = let
        system = "x86_64-linux";
        toplevel = "cardano-sdk";
        subpackages = lib.filterAttrs (k: v: lib.hasPrefix "@cardano-sdk" k) self.packages.${system};
        subpackagesNames = builtins.attrNames subpackages;
        topDependencies =
          builtins.removeAttrs
          self.packages.${system}.${toplevel}.dependencies
          (subpackagesNames ++ [toplevel]);
      in
        lib.recursiveUpdate (
          builtins.mapAttrs (n: _: let
            otherNames = lib.remove n subpackagesNames;
            otherSubpackages = builtins.removeAttrs subpackages [n];
          in {
            # install-method.installMethod = "copy";
            add-inputs.buildInputs = old: old ++ (lib.attrValues topDependencies) ++ [pkgs.nodejs-14_x.pkgs.yarn];
            install-symlinks.postInstall = "ln -s $out/lib/node_modules/${n}/dist $out/dist";
            fix-relative-references.postPatch = let
              references = {
                "@cardano-sdk/blockfrost" = [ "core" "util" ];
                "@cardano-sdk/cardano-services-client" = [ "core" "util" ];
                "@cardano-sdk/cardano-services" = [ "core" "ogmios" "rabbitmq" "util" ];
                "@cardano-sdk/cip2" = [ "core" "util" ];
                "@cardano-sdk/cip30" = [ "core" ];
                "@cardano-sdk/core" = [ "util" ];
                "@cardano-sdk/e2e" = [ "util" "util-dev" "wallet" "cardano-services" ];
                "@cardano-sdk/golden-test-generator" = [ "core" "util" ];
                "@cardano-sdk/ogmios" = [ "core" ];
                "@cardano-sdk/rabbitmq" = [ "core" "util" ];
                "@cardano-sdk/util" = [];
                "@cardano-sdk/util-dev" = [ "core" ];
                "@cardano-sdk/util-rxjs" = [];
                "@cardano-sdk/wallet" = [ "cip2" "cip30" "core" "util-rxjs" "util"];
                "@cardano-sdk/web-extension" = [ "cip30" "core" "wallet" "util-rxjs" "util"];
              };
              replacer = lib.concatMapStrings (name: ''
                substituteInPlace ./src/tsconfig.json \
                  --replace \
                    '"path": "../../${name}/src"' \
                    '"path": "../node_modules/@cardano-sdk/${name}/src"'
              '');
            in ''
              substituteInPlace ./package.json \
                --replace '../../build/cjs-package.json' '${./build/cjs-package.json}' \
                --replace '../../build/esm-package.json' '${./build/esm-package.json}'

              substituteInPlace ./src/tsconfig.json \
                --replace \
                  '"extends": "../../../tsconfig.json"' \
                  '"extends": "${./tsconfig.json}"'

              ${replacer references.${n}}

              mkdir -p dist/{cjs,esm}
            '';
          })
          subpackages
        )
        {
          "chromedriver" = {
            dont-download = {
                buildInputs = old: old ++ [pkgs.chromedriver];
                CHROMEDRIVER_SKIP_DOWNLOAD = "true";
            };
          };
        };
      inject = {
        "express-prom-bundle"."6.4.1" = [
          ["prom-client" "14.0.1"]
        ];
        "express-openapi-validator"."4.13.7" = [
          ["express" "4.17.3"]
        ];
        "isomorphic-ws"."4.0.1" = [
          ["ws" "8.5.0"]
        ];
      };
    })
    // {
      defaultPackage.x86_64-linux = self.packages.x86_64-linux."@cardano-sdk/cardano-services";
      apps.x86_64-linux.default = {
        type = "app";
        program = "${self.defaultPackage.x86_64-linux}/bin/cli";
      };
      checks.x86_64-linux = lib.filterAttrs (k: v: lib.hasPrefix "@cardano-sdk/" k) self.packages.x86_64-linux;
      devShells.x86_64-linux.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs.nodejs-14_x.pkgs; [yarn self.packages.x86_64-linux.cardano-sdk.dependencies.typescript pkgs.nodejs-14_x];
      };
    };
}
