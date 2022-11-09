{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nix-filter.url = "github:numtide/nix-filter";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    nix-filter,
    flake-utils,
  }: {
    packages.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      chromedriverBin = pkgs.fetchurl {
        url = "https://chromedriver.storage.googleapis.com/102.0.5005.61/chromedriver_linux64.zip";
        hash = "sha256-SwB82rvinNOBKT3z8odrHamtMKZZWdUY6nJKst7b9Ts=";
      };
      src = nix-filter.lib.filter {
        root = ./.;
        include = [
          "build"
          "packages"
          "scripts"
          ".yarn"
          ".yarnrc.yml"
          "package.json"
          "tsconfig.json"
          "yarn.lock"
          "yarn-project.nix"
        ];
      };
      project = pkgs.callPackage ./yarn-project.nix {} {inherit src;};

      replaceLine = regex: replacement: s: let
        m = builtins.match "(.*\n)${regex}(\n.*)" s;
      in
        builtins.concatStringsSep "" [
          (builtins.elemAt m 0)
          replacement
          (builtins.elemAt m 1)
        ];
      production-deps = project.overrideAttrs (oldAttrs: {
        name = "cardano-sdk-production-deps";
        configurePhase =
          builtins.replaceStrings
          ["yarn install --immutable --immutable-cache"]
          ["yarn workspaces focus --all --production"]
          oldAttrs.configurePhase;
        # A bunch of deps build binaries using node-gyp that requires Python
        PYTHON = "${pkgs.python3}/bin/python3";
        # node-hid uses pkg-config to find sources
        buildInputs = oldAttrs.buildInputs ++ [pkgs.pkg-config pkgs.libusb1];
      });
    in
      project.overrideAttrs (oldAttrs: {
        # A bunch of deps build binaries using node-gyp that requires Python
        PYTHON = "${pkgs.python3}/bin/python3";
        # chromedriver wants to download the binary
        CHROMEDRIVER_FILEPATH = "${chromedriverBin}";
        # node-hid uses pkg-config to find sources
        buildInputs = oldAttrs.buildInputs ++ [pkgs.pkg-config pkgs.libusb1];
        # run actual build
        buildPhase = ''
          yarn build
        '';
        # override installPhase to only install what's necessary
        installPhase = ''
          runHook preInstall

          mkdir -p $out/libexec/$sourceRoot $out/bin

          test -f ${production-deps}/libexec/$sourceRoot/packages/cardano-services/node_modules && cp -r ${production-deps}/libexec/$sourceRoot/node_modules $out/libexec/$sourceRoot/node_modules
          cp -r scripts $out/libexec/$sourceRoot/scripts
          for p in cardano-services core ogmios util; do
            mkdir -p $out/libexec/$sourceRoot/packages/$p
            cp -r packages/$p/dist $out/libexec/$sourceRoot/packages/$p/dist
            cp -r packages/$p/package.json $out/libexec/$sourceRoot/packages/$p/package.json
          done
          test -f ${production-deps}/libexec/$sourceRoot/packages/cardano-services/node_modules && cp -r ${production-deps}/libexec/$sourceRoot/packages/cardano-services/node_modules $out/libexec/$sourceRoot/packages/cardano-services/node_modules
          cp -r ${production-deps}/libexec/$sourceRoot/packages/cardano-services/config $out/libexec/$sourceRoot/packages/cardano-services/config

          cd "$out/libexec/$sourceRoot"

          runHook postInstall
        '';
        # add a bin script that should be used to run cardano-services CLI
        postInstall = ''
          cat > $out/bin/cli <<EOF
          #!${pkgs.bash}/bin/bash
          exec "${pkgs.nodejs}/bin/node" "$out/libexec/$sourceRoot/packages/cardano-services/dist/cjs/cli.js" "\$@"
          EOF
          chmod a+x $out/bin/cli
        '';
        meta.mainProgram = "cli";
      });

    apps = flake-utils.lib.eachDefaultSystemMap (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      config-update = flake-utils.lib.mkApp {
        drv = pkgs.writeShellApplication {
          name = "config-update";
          runtimeInputs = with pkgs; [git git-subrepo];
          text = ''
            git subrepo pull packages/cardano-services/config --message='chore: git subrepo pull packages/cardano-services/config' "$@"
          '';
        };
      };
    });
  };
}
