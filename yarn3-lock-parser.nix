{ inputs }:

let

  inherit (inputs.nixpkgs) lib;

in rec {

  raw = __readFile ./yarn.lock;

  parsed = parseYarnLockV3 raw;

  parseYarnLockV3 = original: let
    lines = lib.filter (line: !(
      (builtins.match "[[:space:]]*#.*" line != null)
      || (builtins.match "[[:space:]]*" line != null)
    )) (lib.splitString "\n" original);
    decode = s: if lib.hasPrefix "\"" s then builtins.fromJSON s else s;
    doTrace = num: builtins.trace "parsed ${toString num} yarn.lock dependencies…";
    parsed = lib.foldl' (acc: line: let
      ms = builtins.match "( *)((\"[^\"]+)?[^:]+):[[:space:]]*(.*)" line;
    in if ms == null || lib.length(ms) != 4 then acc else let
      depth = __stringLength (__elemAt ms 0) / 2;
      key = decode (__elemAt ms 1);
      val = decode (__elemAt ms 3);
      nextAcc.prevPath = (lib.take depth acc.prevPath) ++ [key];
      nextAcc.result = lib.updateManyAttrsByPath [{
        path = nextAcc.prevPath;
        update = old: if val == "" then {} else val;
      }] acc.result;
      nextAcc.numDeps = acc.numDeps + (if depth == 0 then 1 else 0);
    in
      # XXX: without tracing every few deps, there's a segfault for larger files; deepSeq doesn’t help
      (if depth == 0 && lib.mod nextAcc.numDeps 100 == 0
       then doTrace (__length (__attrNames nextAcc.result))
       else (a: a))
      nextAcc) {
        result = {};
        prevPath = [];
        numDeps = 0;
      } lines;
  in doTrace parsed.numDeps parsed.result;

}
