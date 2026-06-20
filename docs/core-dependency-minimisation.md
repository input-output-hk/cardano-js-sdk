# `@cardano-sdk/core` dependency minimisation

Reducing the external runtime dependencies of `@cardano-sdk/core` to shrink the
dependency tree, install/bundle size, and supply-chain attack surface that
consumers inherit when they install a published `@cardano-sdk/*` package.

`core` is the most depended-upon package in the SDK, so every external runtime
dependency it carries propagates into almost every consumer's production closure.

## Method

- **Closure-aware, not size-naive.** A dependency is only worth removing from
  `core` if it actually leaves `core`'s **production closure**. Several of
  `core`'s deps (`lodash`, `ts-log`, `ts-custom-error`) are *also* declared by
  `@cardano-sdk/util` and `@cardano-sdk/crypto` (both workspace deps of `core`),
  so removing them from `core` alone is cosmetic — they remain in the closure
  via those packages. Those are out of scope here (they belong to a separate
  repo-wide pass).
- **Differential equivalence for consensus-sensitive code.** Where a dependency
  feeds serialization that affects on-chain bytes, the local replacement is
  proven **byte-for-byte identical** to the library across a corpus *before* the
  dependency is removed, then locked in with vector-based unit tests.
- **Trusted/audited deps are kept**, not reimplemented (reimplementing them would
  *increase* risk).

## Decision table

| Dep | Closure scope | Decision | Rationale |
|---|---|---|---|
| `web-encoding` | unique to core | **Removed** | redundant `TextDecoder` polyfill; global since Node 11 |
| `@foxglove/crc` | unique to core | **Removed** | ~15-line CRC-32 (Byron checksum) |
| `ip-address` | unique to core | **Removed** | ~45-line IPv4/IPv6 parse (pool-relay serialization); differential-proven vs lib |
| `fraction.js` | unique to core | **Keep** | core uses the single-arg decimal constructor (`new Fraction(0.3)`), i.e. its continued-fraction *approximation* — reimplementing that byte-exactly for consensus protocol params (`UnitInterval`, `ExUnitPrices`) is not low-risk; differential testing can't exhaustively cover the decimal input space |
| `@scure/base` | unique to core | **Keep** | audited, zero-dep, gold-standard encoding lib |
| `@biglup/is-cid` | unique to core | **Keep** | trusted — authored by a js-sdk core maintainer |
| `lodash` | shared via util+crypto | **Keep (here)** | removal cosmetic for core; repo-wide pass needed |
| `ts-log` | shared via util+crypto | **Keep (here)** | types-only; removal cosmetic for core |
| `ts-custom-error` | shared via util+crypto | **Keep (here)** | removal cosmetic for core |

## Removals & impact

> Two impact metrics matter and differ. **Transitive closure** = the distinct
> packages a dependency pulls in (the surface a consumer inherits). **Net
> monorepo lock** = how many resolutions actually leave `yarn.lock` — smaller,
> because many transitive packages are shared with dev/other workspaces. The
> first is the consumer-facing supply-chain number.

| Dep | Transitive closure removed | Install size | Net `yarn.lock` Δ | Replacement | Tests |
|---|---|---|---|---|---|
| `web-encoding` | **30 packages** (`util@0.12` polyfill chain + `@zxing/text-encoding`) | **~9.5 MB** | −3 (rest shared) | global `TextDecoder` | existing decode suites + full core (992) |
| `@foxglove/crc` | 1 package | 168 KB | −1 | local `crc32.ts` | new `crc32.test.ts` (4 canonical vectors) + Byron round-trips |
| `ip-address` | 1 package (zero-dep in v10) | 336 KB | −1 | local IPv4/IPv6 in `ipUtils.ts` | differential-proven vs lib (26 cases) + new vector tests |

**`core` external runtime deps: 9 → 6** (`web-encoding`, `@foxglove/crc`,
`ip-address` removed). The headline supply-chain win is `web-encoding`: a
30-package polyfill subtree and ~9.5 MB removed from `core`'s production closure,
for a polyfill that has been unnecessary since Node 11 (`TextDecoder` is a global)
and in all bundler-targeted browsers. Remaining: `fraction.js` is a candidate
(deferred pending differential treatment); `@scure/base` and `@biglup/is-cid` are
kept by design; `lodash`/`ts-log`/`ts-custom-error` need a repo-wide pass.

## Notes

- `web-encoding`'s `util@0.12` chain (`call-bind`, `get-intrinsic`,
  `is-typed-array`, …) is shared with other workspaces, so the monorepo
  `yarn.lock` only shrinks by 3 — but consumers installing `@cardano-sdk/core`
  no longer pull that subtree into their production closure.
- All replacements are behaviour-preserving; the full `core` test suite stays
  green after each.
