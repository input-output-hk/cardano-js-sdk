{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nosys.url = "github:divnix/nosys";
  inputs.incl.url = "github:divnix/incl";

  outputs = inputs @ {nosys, ...}:
    nosys inputs ({
      nixpkgs,
      incl,
      ...
    }: let
      pkgs = nixpkgs.legacyPackages;
      inherit (pkgs) lib fetchurl callPackage writeShellApplication python3;
      inherit (builtins) match concatStringsSep elemAt replaceStrings;
    in {
      packages.default = let
        chromedriverBin = fetchurl {
          url = "https://chromedriver.storage.googleapis.com/102.0.5005.61/chromedriver_linux64.zip";
          hash = "sha256-SwB82rvinNOBKT3z8odrHamtMKZZWdUY6nJKst7b9Ts=";
        };
        src = incl ./. [
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
        project = callPackage ./yarn-project.nix {} {inherit src;};

        replaceLine = regex: replacement: s: let
          m = match "(.*\n)${regex}(\n.*)" s;
        in
          concatStringsSep "" [
            (elemAt m 0)
            replacement
            (elemAt m 1)
          ];
        production-deps = project.overrideAttrs (oldAttrs: {
          name = "cardano-sdk-production-deps";
          configurePhase =
            replaceStrings
            ["yarn install --immutable --immutable-cache"]
            ["yarn workspaces focus --all --production"]
            oldAttrs.configurePhase;
          # A bunch of deps build binaries using node-gyp that requires Python
          PYTHON = lib.getExe python3;
          # node-hid uses pkg-config to find sources
          buildInputs = oldAttrs.buildInputs ++ [pkgs.pkg-config pkgs.libusb1];

          installPhase = ''
            runHook preInstall
            mkdir -p $out/libexec $out/bin
            # Move the entire project to the output directory.
            mv $PWD "$out/libexec/$sourceRoot"
            cd "$out/libexec/$sourceRoot"
            # Invoke a plugin internal command to setup binaries.
            yarn nixify install-bin $out/bin
            runHook postInstall
          '';
        });
      in
        project.overrideAttrs (oldAttrs: {
          # A bunch of deps build binaries using node-gyp that requires Python
          PYTHON = lib.getExe python3;
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

            cp -r ${production-deps}/libexec/$sourceRoot/node_modules $out/libexec/$sourceRoot/node_modules
            cp -r scripts $out/libexec/$sourceRoot/scripts
            for p in cardano-services core ogmios util crypto projection projection-typeorm util-rxjs; do
              mkdir -p $out/libexec/$sourceRoot/packages/$p
              cp -r packages/$p/dist $out/libexec/$sourceRoot/packages/$p/dist
              cp -r packages/$p/package.json $out/libexec/$sourceRoot/packages/$p/package.json
            done
            cp -r ${production-deps}/libexec/$sourceRoot/packages/cardano-services/config $out/libexec/$sourceRoot/packages/cardano-services/config

            cd "$out/libexec/$sourceRoot"

            runHook postInstall
          '';
          # add a bin script that should be used to run cardano-services CLI
          postInstall = ''
            cat > $out/bin/cli <<EOF
            #!${lib.getExe pkgs.bash}
            exec "${lib.getExe pkgs.nodejs}" "$out/libexec/$sourceRoot/packages/cardano-services/dist/cjs/cli.js" "\$@"
            EOF
            chmod a+x $out/bin/cli
          '';
          meta.mainProgram = "cli";
          passthru.nodejs = pkgs.nodejs;
          passthru.production-deps = production-deps;
        });

      apps = {
        config-update = {
          type = "app";
          program = lib.getExe (writeShellApplication {
            name = "config-update";
            runtimeInputs = with pkgs; [git git-subrepo];
            text = ''
              git subrepo pull packages/cardano-services/config --message='chore: git subrepo pull packages/cardano-services/config' "$@"
            '';
          });
        };
      };
    });
}
