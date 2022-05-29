import { getLastCommit } from 'git-last-commit';
// eslint-disable-next-line unicorn/prefer-node-protocol
import { promisify } from 'util';

export const getLastCommitPromise = promisify(getLastCommit);
