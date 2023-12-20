let
  inherit (inputs) nixpkgs std self;
in {
  cardano-services = let
    src = std.incl self [
      "build"
      "packages"
      "scripts"
      ".yarn"
      ".yarnrc.yml"
      ".eslintrc.js"
      ".prettierrc"
      "complete.eslintrc.js"
      "eslint.tsconfig.json"
      "package.json"
      "tsconfig.json"
      "yarn.lock"
      "yarn-project.nix"
    ];
    project = nixpkgs.callPackage (self + /yarn-project.nix) {} {inherit src;};

    production-deps = project.overrideAttrs (oldAttrs: {
      name = "cardano-sdk-production-deps";
      configurePhase =
        builtins.replaceStrings
        ["yarn install --immutable --immutable-cache"]
        ["yarn workspaces focus --all --production"]
        oldAttrs.configurePhase;
      # A bunch of deps build binaries using node-gyp that requires Python
      PYTHON = "${nixpkgs.python3}/bin/python3";
      # node-hid uses pkg-config to find sources
      buildInputs = oldAttrs.buildInputs ++ [nixpkgs.pkg-config nixpkgs.libusb1];

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

    chromedriverVersion = "120.0.6099.71";
    chromedriver = nixpkgs.fetchurl {
      url = "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/${chromedriverVersion}/linux64/chromedriver-linux64.zip";
      hash = "sha256-X8bia1BaLQm5WKn5vdShpQ4A7sPNZ8lgmeXoYj2earc=";
    };
  in
    project.overrideAttrs (oldAttrs: {
      # A bunch of deps build binaries using node-gyp that requires Python
      PYTHON = "${nixpkgs.python3}/bin/python3";
      # playwright build fixes
      PLAYWRIGHT_BROWSERS_PATH = nixpkgs.playwright-driver.browsers;
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = 1;
      CHROMEDRIVER_FILEPATH = chromedriver;
      # node-hid uses pkg-config to find sources
      buildInputs = oldAttrs.buildInputs ++ [nixpkgs.pkg-config nixpkgs.libusb1];
      # run actual build
      buildPhase = ''
        yarn workspace @cardano-sdk/cardano-services run build
      '';
      # override installPhase to only install what's necessary
      installPhase = ''
        runHook preInstall

        mkdir -p $out/libexec/$sourceRoot $out/bin
        yarn workspace @cardano-sdk/cardano-services-client run build:version

        cp -r ${production-deps}/libexec/$sourceRoot/node_modules $out/libexec/$sourceRoot/node_modules
        cp -r scripts $out/libexec/$sourceRoot/scripts
        for p in cardano-services cardano-services-client core ogmios util crypto projection projection-typeorm util-rxjs; do
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
        #!${nixpkgs.bash}/bin/bash
        exec "${nixpkgs.nodejs}/bin/node" "$out/libexec/$sourceRoot/packages/cardano-services/dist/cjs/cli.js" "\$@"
        EOF
        chmod a+x $out/bin/cli
      '';
      meta.mainProgram = "cli";
      meta.description = "The Cardano Services CLI";
      passthru.nodejs = nixpkgs.nodejs;
      passthru.production-deps = production-deps;
    });
}
