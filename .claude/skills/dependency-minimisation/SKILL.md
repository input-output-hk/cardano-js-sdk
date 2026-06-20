# Dependency minimisation & safe in-house replacement

A repeatable process for removing external runtime dependencies from a package to
shrink its dependency tree, install/bundle size, and supply-chain attack surface —
without changing behaviour, and with the evidence to make the PR easy to approve.

Environment: **Yarn 3 (berry), `nodeLinker: node-modules`**, workspaces under
`packages/*`, published packages are the non-`private` `@cardano-sdk/*`. Worked
example: `docs/core-dependency-minimisation.md` (the `@cardano-sdk/core` pass).

## Principles (in priority order)

1. **Closure-aware, not size-naive.** Only removals that actually leave the
   target's **production closure** count. A dep that is *also* declared by a
   workspace dependency of the target (e.g. `core` → `util`/`crypto` both
   declaring `lodash`/`ts-log`) will remain in the closure after you remove it
   from the target — so removing it there is **cosmetic**. Compute the closure
   before picking targets (Step 1).
2. **Two impact metrics, reported separately.** *Transitive closure* = the
   distinct packages a dep pulls in (the surface a consumer inherits — the real
   supply-chain number). *Net `yarn.lock` delta* = how many resolutions actually
   leave the lock, which is smaller because transitive packages are often shared
   with dev/other workspaces. Reporting only the lock delta understates the
   consumer-facing win; reporting only size understates/overstates surface.
3. **Differential equivalence before removal** for anything feeding serialization
   or consensus-affecting bytes. Prove the local replacement is **byte-for-byte
   identical** to the library across a corpus *while the library is still
   installed*, then lock it in with vector-based unit tests (Step 4). Never swap
   consensus code on inspection alone.
4. **Keep trusted/audited deps — reimplementing them increases risk.** Examples:
   `@scure/base` (audited, zero-dep, crypto-grade encoding); a dep authored/
   maintained by a core maintainer of this repo. The supply-chain goal is *fewer
   untrusted publishers*, not *zero dependencies*. Confirm "trusted" with the
   user, don't assume.
5. **Atomic commits, suite green after each.** One dependency per commit, full
   target-package test suite green every time; required compat folded in.

## Process

### 1. Compute the production closure and classify each external dep
A dependency is consumer-facing iff reachable via production (`dependencies` +
`optionalDependencies`) edges from a non-private workspace. BFS `node_modules`
with `require.resolve('<dep>/package.json', { paths: [fromDir] })`.

For each of the target's external deps, classify:
- **Unique to target** (not declared by any workspace dep of the target) →
  removal genuinely shrinks the closure. **Candidate.**
- **Shared via a workspace dep** (e.g. also in `util`/`crypto`) → removal cosmetic
  for the target. **Defer to a repo-wide pass.**

Check which workspace deps the target pulls, then compare external-dep sets:
```bash
node -e '
const get=p=>Object.keys(require(`./packages/${p}/package.json`).dependencies||{}).filter(d=>!d.startsWith("@cardano-sdk/"));
const target=get("core"), shared=new Set([...get("util"),...get("crypto")]);
for(const d of target.sort()) console.log(d.padEnd(20), shared.has(d)?"SHARED (cosmetic)":"UNIQUE (clears closure)");'
```

### 2. Rank candidates by feasibility AND value
For each unique candidate, gather: install size (`du -sh node_modules/<dep>`),
transitive closure size (Step 3 script), reimplementation LoC, existing test
coverage, and consensus-sensitivity. Order **smallest/safest first** — but
re-rank when evidence changes the picture (e.g. a "small" validator that
delegates to a large parser with *no* existing tests is **hard**, not easy).

### 3. Measure transitive impact (for the PR)
From the **base** lockfile (before your changes), compute each dep's transitive
closure — the consumer-facing number:
```bash
git show <base-branch>:yarn.lock > /tmp/base.lock
# BFS the lock: for each block, parse descriptors + version + nested `dependencies:`,
# then walk from <dep> following dependency names. Report distinct name@version count.
```
Also report the **net lock delta** (`grep -cE '^"?[^ #].*:$' yarn.lock` before vs
after) so the difference between "subtree pulled" and "resolutions actually
removed" is explicit. The gap is the shared-transitive packages.

### 4. Replace, proving equivalence
Implement the replacement in the same file/module. For consensus/serialization
code, write a **throwaway differential harness** that imports BOTH your impl and
the library and asserts identical output over a corpus (valid + edge + invalid
inputs); run it **from inside the repo** (so `node_modules` resolves) while the
lib is still installed:
```bash
# corpus must include the awkward cases the domain actually uses
# (e.g. IPv6 '::' compression + embedded IPv4 '::ffff:10.3.2.10')
node ./diff.cjs   # NOT /tmp — require() won't resolve the dep from outside the repo
```
Only once it reports full equivalence: delete the dep, and commit the local impl
with **vector-based unit tests** (canonical published vectors for algorithms —
e.g. CRC-32 `"123456789" → 0xCBF43926`, empty `→ 0`).

### 5. Remove, validate, commit
```bash
node -e 'const fs=require("fs");const f="packages/<pkg>/package.json";const p=JSON.parse(fs.readFileSync(f));delete p.dependencies["<dep>"];fs.writeFileSync(f,JSON.stringify(p,null,2)+"\n")'
YARN_ENABLE_IMMUTABLE_INSTALLS=false yarn install
grep -c '<dep>@' yarn.lock          # expect 0 (and 0 for its now-orphaned transitives)
find packages/<pkg> -maxdepth 2 -name '*.tsbuildinfo' -delete   # avoid incremental-tsc masking
yarn workspace @cardano-sdk/<pkg> build && yarn workspace @cardano-sdk/<pkg> test
```
One commit per dep; `refactor(<pkg>): …` with the closure/size impact in the body.

### 6. Document
Keep a living `docs/<pkg>-dependency-minimisation.md`: method, decision table
(every external dep + keep/remove/defer + rationale), and an impact table
(transitive closure removed · install size · net lock delta · replacement ·
tests). The PR description draws from it.

## Gotchas

- **Closure ≠ lock delta.** Removing a 30-package subtree can drop only 3 lock
  entries if 27 are shared with other workspaces — but they still leave the
  *target's* consumer closure. Always state both.
- **A polyfill may already be dead.** `TextDecoder`/`TextEncoder` are Node
  globals since v11; `structuredClone`/`Object.groupBy` since 17/21. Check the
  engine floor before assuming a polyfill is needed — it was likely redundant
  even before the latest Node bump (don't attribute the removal to the bump).
- **ESM-only deps don't resolve via `require()`** — `require.resolve('<dep>')`
  may throw even though it's installed; resolve `'<dep>/package.json'` instead,
  and run differential scripts with the same module system the dep ships.
- **Differential scripts must live inside the repo**, not `/tmp` — `node_modules`
  won't resolve from outside the workspace.
- **Lint hex-literal conflict:** `unicorn/number-literal-case` (this repo) and
  `prettier/prettier` can disagree on hex casing; standalone `npx eslint --fix`
  may pick uppercase, which prettier then rejects. **Prettier is authoritative** —
  run `npx prettier --write` and match the existing convention (lowercase hex,
  `_` separators every 2 digits: `0xff_ff_ff_ff`). The project-wide `yarn lint`
  may OOM; lint the changed files directly with `NODE_OPTIONS=--max-old-space-size=4096`.
- **zsh doesn't word-split unquoted vars** — iterate dep lists with an explicit
  `for d in "a" "b"` array, not `for d in $DEPS`.
- **Confirm "trusted" before keeping a dep on trust** — provenance/authorship
  claims (e.g. "written by a maintainer") should come from the user or be
  verified, not assumed from the package name.

## Reference
Worked example: `docs/core-dependency-minimisation.md`. Complements the
`dependency-vulnerability-remediation` skill (that one closes CVEs; this one
removes deps you don't need at all).
