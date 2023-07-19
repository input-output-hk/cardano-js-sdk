let
  inherit (inputs) std self;

  # TODO: express this as OCI labels (what they are for)
  BUILD_INFO = builtins.toJSON {
    inherit (self) lastModified lastModifiedDate rev;
    shortRev = self.shortRev or "no rev";
    extra = {
      sourceInfo = self;
      narHash = self.narHash;
      path = self.outPath;
    };
  };
in {
  server = std.lib.ops.mkStandardOCI {
    name = "926093910549.dkr.ecr.us-east-1.amazonaws.com/cardano-services";
    operable = cell.operables.server;
    config.Env = [
      "BUILD_INFO=${BUILD_INFO}"
    ];
    meta.description = "Minimal Provider Server OCI Image";
  };
}
