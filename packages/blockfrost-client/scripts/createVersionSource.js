const fs = require('fs');
const path = require('path');
const { argv, exit } = require('process');
const { deepEqual } = require('assert');

const cardanoServicesSrc = path.join('..', '..', 'cardano-services', 'src');

const apiVersion = Object.fromEntries(
  Object.entries({
    assetInfo: 'Asset',
    chainHistory: 'ChainHistory',
    handle: 'Handle',
    networkInfo: 'NetworkInfo',
    rewards: 'Rewards',
    root: 'Http',
    stakePool: 'StakePool',
    txSubmit: 'TxSubmit',
    utxo: 'Utxo'
  }).map(([providerName, openApiDir]) => [
    providerName,
    require(path.join(cardanoServicesSrc, openApiDir, 'openApi.json')).info.version
  ])
);

const supportedVersionsFile = path.join(__dirname, '../supportedVersions.json');
const sameMajorVersion = (a) => (b) => {
  const [majorA] = a.split('.');
  const [majorB] = b.split('.');
  return majorA === majorB;
};
const supportedVersions = (() => {
  let rv = {};
  if (fs.existsSync(supportedVersionsFile)) {
    const data = fs.readFileSync(supportedVersionsFile, { encoding: 'utf8' });
    rv = JSON.parse(data);
  }
  for (const [api, version] of Object.entries(apiVersion)) {
    const previouslySupported = rv[api] ?? [];
    rv[api] = previouslySupported.includes(apiVersion[api])
      ? previouslySupported
      : [...previouslySupported.filter(sameMajorVersion(version)), version];
  }
  return rv;
})();

const create = () => {
  fs.writeFileSync(supportedVersionsFile, `${JSON.stringify(supportedVersions, null, 2)}\n`, {
    encoding: 'utf8',
    flag: 'w'
  });
  const contents = `// auto-generated using ../scripts/createVersionSource.js
export const apiVersion = ${JSON.stringify(apiVersion, null, 2)};
`;
  fs.writeFileSync(path.join(__dirname, '../src/version.ts'), contents, { encoding: 'utf8', flag: 'w' });
};

switch (argv[2]) {
  case '--check':
    try {
      deepEqual(JSON.parse(fs.readFileSync(supportedVersionsFile, { encoding: 'utf8' })), supportedVersions);
      exit(1);
    } catch {
      exit(0);
    }
  // eslint-disable-next-line no-fallthrough
  case '--create':
    create();
    break;
  default:
    // eslint-disable-next-line no-console
    console.error('Usage: createVersionSource [--check|--create]');
    exit(1);
}
