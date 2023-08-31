const fs = require('fs');
const path = require('path');

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

const version = JSON.stringify(apiVersion, null, 2);
const contents = `// auto-generated using ../scripts/createVersionSource.js
export const apiVersion = ${version};
`;

fs.writeFileSync(path.join(__dirname, '../src/version.ts'), contents, { encoding: 'utf8', flag: 'w' });
fs.writeFileSync(path.join(__dirname, '../version.json'), `${version}\n`, { encoding: 'utf8', flag: 'w' });
