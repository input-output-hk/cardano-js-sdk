import * as envalid from 'envalid';

export const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str(),
  ASSET_PROVIDER_PARAMS: envalid.json({ default: {} }),
  BLOCKFROST_API_KEY: envalid.str(),
  CHAIN_HISTORY_PROVIDER: envalid.str(),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PARAMS: envalid.json({ default: {} }),
  KEY_MANAGEMENT_PROVIDER: envalid.str(),
  NETWORK_INFO_PROVIDER: envalid.str(),
  NETWORK_INFO_PROVIDER_PARAMS: envalid.json({ default: {} }),
  POOL_ID_1: envalid.str(),
  POOL_ID_2: envalid.str(),
  REWARDS_PROVIDER: envalid.str(),
  REWARDS_PROVIDER_PARAMS: envalid.json({ default: {} }),
  STAKE_POOL_PROVIDER: envalid.str(),
  STAKE_POOL_PROVIDER_PARAMS: envalid.json({ default: {} }),
  TX_SUBMIT_PROVIDER: envalid.str(),
  TX_SUBMIT_PROVIDER_PARAMS: envalid.json({ default: {} }),
  UTXO_PROVIDER: envalid.str(),
  UTXO_PROVIDER_PARAMS: envalid.json({ default: {} })
});
