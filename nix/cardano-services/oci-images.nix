let
  inherit (inputs) std self;

  # TODO: express this as OCI labels (what they are for)
  buildInfo = builtins.toJSON {
    inherit (self) lastModified lastModifiedDate rev;
    shortRev = self.shortRev or "no rev";
    extra = {
      inherit (self) narHash;
      sourceInfo = self;
      path = self.outPath;
    };
  };
in {
  cardano-services = std.lib.ops.mkStandardOCI {
    name = "926093910549.dkr.ecr.us-east-1.amazonaws.com/cardano-services";
    operable = cell.operables.cardano-services;
    meta.description = "Minimal Cardano Services OCI Image";
    meta.versions = builtins.fromJSON (builtins.readFile (self + /packages/cardano-services-client/version.json));
    meta.buildInfo = buildInfo;
  };
}
