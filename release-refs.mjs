// Lists recent release (version) commits with the @cardano-sdk/core version each carries,
// so a maintainer can nominate a real release ref (and its versions) for the `release`
// workflow's `ref` input. workflow_dispatch dropdowns can't be populated from git history,
// so this is the discovery aid. See .github/workflows/release.yaml.
import { execFileSync } from 'node:child_process';

// Invoke git directly (no shell) — portable and free of quoting pitfalls.
const git = (...args) => execFileSync('git', args, { encoding: 'utf8' });

// Authoritative match is on the commit SUBJECT (stable + rc). `git log --grep` matches the
// whole message (subject + body), so it's only a coarse pre-filter to keep the walk cheap;
// this regex then drops anything (reverts, merges) that merely mentions the subject in its body.
const SUBJECT_RE = /^ci: publish (rc )?packages \[skip actions\]$/;
const limit = Number.parseInt(process.argv[2], 10) || 20;
const US = '\x1f'; // unit separator — a field delimiter that can't appear in the log fields

const rows = git('log', '-F', '--grep=ci: publish', `--format=%h${US}%H${US}%ci${US}%s`, '-n', String(limit * 3))
  .split('\n')
  .filter(Boolean)
  .map((line) => line.split(US))
  .filter(([, , , subject]) => SUBJECT_RE.test(subject))
  .slice(0, limit);

if (rows.length === 0) {
  console.log('No release commits found.');
  process.exit(0);
}

for (const [short, full, date] of rows) {
  let version = '?';
  try {
    version = JSON.parse(git('show', `${full}:packages/core/package.json`)).version;
  } catch {
    // packages/core/package.json may not exist at very old commits — leave as '?'
  }
  console.log(`${short}  core@${version.padEnd(11)}${date}`);
}
