{
  inputs = {
    # TODO: change to upstream when https://github.com/nix-community/dream2nix/pull/160 is merged
    dream2nix.url = "github:tgunnoe/dream2nix/yarn-npm-package-versions";
  };

  outputs = {
    self,
    dream2nix,
    nixpkgs,
  } @ inp: let
    inherit (nixpkgs.legacyPackages.x86_64-linux) pkgs;
    inherit (pkgs) lib;

    dream2nix = inp.dream2nix.lib2.init {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
    };
  in
    (dream2nix.makeFlakeOutputs {
      source = ./.;
      settings = [
        {subsystemInfo.noDev = false;}
      ];
      packageOverrides =
        lib.recursiveUpdate (
          builtins.mapAttrs (
            n: _:
              if lib.hasPrefix "@" n
              then
                {
                  add-inputs.buildInputs = old: old ++ [self.packages.x86_64-linux.cardano-sdk.dependencies.typescript pkgs.nodejs-14_x.pkgs.yarn];
                  copy-tsconfig.postPatch = ''
                    substituteInPlace ./src/tsconfig.json --replace \
                      '"extends": "../../../tsconfig.json"' \
                      '"extends": "./tsconfig-copy.json"'
                    cp ${./.}/tsconfig.json \
                      ./src/tsconfig-copy.json
                  '';
                  install-symlinks = {
                    installPhase = ''
                      mkdir -p $out/bin
                      ln -s $out/lib/node_modules/${n}/dist $out/dist
                    '';
                  };
                }
                // lib.optionalAttrs (builtins.match ''@cardano-sdk/(util-dev|cardano-services|ogmios|cardano-services-client|rabbitmq)'' n != null) {
                  update-references = {
                    prePatch = ''
                      substituteInPlace ./src/tsconfig.json --replace \
                        '"path": "../../core/src"' \
                        '"path": "${self.packages.x86_64-linux."@cardano-sdk/core"}/lib/node_modules/@cardano-sdk/core/src"'
                    '';
                  };
                  add-type-notation = {
                    prePatch = ''
                      echo -e "import _ from \"@cardano-sdk/core/node_modules/@cardano-ogmios/schema\";\n$(cat src/Cardano/types/TxSubmissionErrors.ts)" > src/Cardano/types/TxSubmissionErrors.ts
                    '';
                  };
                }
              else {}
          )
          self.packages.x86_64-linux
        )
        {
          "@cardano-sdk/core" = {
            add-type-notation = {
              prePatch = ''
                echo -e "import _ from \"@cardano-sdk/core/node_modules/@cardano-ogmios/schema\";\n$(cat src/Cardano/types/TxSubmissionErrors.ts)" > src/Cardano/types/TxSubmissionErrors.ts
                substituteInPlace ./src/Cardano/util/subtractValueQuantities.ts \
                  --replace "../types"  "@cardano-sdk/core/src/Cardano/types"
              '';
            };
          };
          "@cardano-sdk/cardano-services" = {
            update-references-2 = {
              postPatch = old:
                lib.concatStrings [
                  old
                  ''
                    substituteInPlace ./src/tsconfig.json \
                    --replace \
                      '"path": "../../ogmios/src"' \
                      '"path": "${self.packages.x86_64-linux."@cardano-sdk/ogmios"}/lib/node_modules/@cardano-sdk/ogmios/src"' \
                    --replace \
                      '"path": "../../rabbitmq/src"' \
                      '"path": "${self.packages.x86_64-linux."@cardano-sdk/rabbitmq"}/lib/node_modules/@cardano-sdk/rabbitmq/src"'
                  ''
                ];

              installPhase = old:
                lib.concatStrings [
                  old
                  ''
                    mkdir -p $out/bin
                    cat << EOF > $out/bin/cli
                    ${pkgs.nodejs-14_x}/bin/node "$out/dist/cli.js"
                    EOF
                    
                    chmod +x "$out/bin/cli"
                  ''
                ];
            };
          };
        };

      inject = {
        "@cardano-sdk/util-dev"."0.2.0" = [
          ["jest" "27.5.1"]
          ["@types/jest" "26.0.24"]
          ["typescript" "4.6.3"]
        ];
        "@cardano-sdk/cardano-services-client"."0.2.0" = [
          ["typescript" "4.6.3"]
        ];
        "@cardano-sdk/ogmios"."0.2.0" = [
          ["typescript" "4.6.3"]
          ["@cardano-sdk/core" "0.2.0"]
        ];
        "@cardano-sdk/rabbitmq"."0.2.0" = [
          ["typescript" "4.6.3"]
          ["@cardano-sdk/core" "0.2.0"]
        ];
        "@cardano-sdk/cardano-services"."0.2.0" = [
          ["@cardano-sdk/rabbitmq" "0.2.0"]
          ["@cardano-sdk/core" "0.2.0"]
          ["@types/node" "14.18.12"]
        ];
      };

      sourceOverrides = _: {
      };
    })
    // {
      devShell.x86_64-linux = pkgs.mkShell {
        nativeBuildInputs = with pkgs.nodejs-14_x.pkgs; [yarn self.packages.x86_64-linux.cardano-sdk.dependencies.typescript pkgs.nodejs-14_x];
      };
    };
}
