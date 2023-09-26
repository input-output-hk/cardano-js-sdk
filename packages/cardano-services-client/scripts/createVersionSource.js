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

const versionFile = path.join(__dirname, '../version.json');
const create = () => {
  const version = JSON.stringify(apiVersion, null, 2);
  const contents = `// auto-generated using ../scripts/createVersionSource.js
  export const apiVersion = ${version};
  `;

  fs.writeFileSync(path.join(__dirname, '../src/version.ts'), contents, { encoding: 'utf8', flag: 'w' });
  fs.writeFileSync(versionFile, `${version}\n`, { encoding: 'utf8', flag: 'w' });
};

switch (argv[2]) {
  case '--check':
    try {
      deepEqual(JSON.parse(fs.readFileSync(versionFile, { encoding: 'utf8' })), apiVersion);
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
