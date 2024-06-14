// cSpell:ignore njson

import { Cardano, CardanoNode, CardanoNodeUtil, WSMessage, WSRequest } from '@cardano-sdk/core';
import { InMemoryCache } from '../InMemoryCache';
import { NJSON } from 'next-json';
import { Pool } from 'pg';
import { ProtocolParamsModel } from '../NetworkInfo/DbSyncNetworkInfoProvider/types';
import { toProtocolParams } from '../NetworkInfo/DbSyncNetworkInfoProvider/mappers';

const getLovelaceSupply = async (db: Pool, maxLovelaceSupply: Cardano.Lovelace) => {
  const query = 'SELECT utxo + rewards AS circulating, reserves FROM ada_pots ORDER BY id DESC LIMIT 1';
  const { rows } = await db.query<{ circulating: string; reserves: string }>(query);
  const [{ circulating, reserves }] = rows;

  return { lovelaceSupply: { circulating: BigInt(circulating), total: maxLovelaceSupply - BigInt(reserves) } };
};

// committee_term_limit min_committee_size
const getProtocolParameters = async (db: Pool) => {
  const query = `\
SELECT epoch_param.*, cost_model.costs FROM epoch_param
  LEFT JOIN cost_model ON cost_model.id = epoch_param.cost_model_id
  ORDER BY epoch_no DESC NULLS LAST LIMIT 1`;
  const { rows } = await db.query<ProtocolParamsModel>(query);
  const [row] = rows;

  return { protocolParameters: toProtocolParams(row) };
};

const getStake = async (cardanoNode: CardanoNode, db: Pool) => {
  const [live, active] = await Promise.all([
    cardanoNode.stakeDistribution().then(CardanoNodeUtil.toLiveStake),
    (async () => {
      const { rows } = await db.query<{ stake: string }>(
        'SELECT COALESCE(SUM(amount), 0) AS stake FROM epoch_stake WHERE epoch_no = (SELECT MAX(no) FROM epoch) - 1'
      );
      const [{ stake }] = rows;

      return BigInt(stake);
    })()
  ]);

  return { stake: { active, live } };
};

export interface HandleRequestOptions {
  /** The cache object.  */
  cache: InMemoryCache;

  /** The `CardanoNode` object. */
  cardanoNode: CardanoNode;

  /** The PostgreSQL Pool. */
  db: Pool;

  /** The `GenesisData` object */
  genesis: Cardano.CompactGenesis;
}

export const handleRequest = (options: HandleRequestOptions, request: WSRequest): Promise<WSMessage['response']> => {
  const { cache, cardanoNode, db, genesis } = options;
  const { eraSummaries, genesisParameters, lovelaceSupply, protocolParameters, stake } = request;

  if (eraSummaries) return cache.get('eraSummaries', async () => ({ eraSummaries: await cardanoNode.eraSummaries() }));
  if (genesisParameters) return Promise.resolve({ genesisParameters: genesis });
  if (lovelaceSupply) return cache.get('lovelaceSupply', () => getLovelaceSupply(db, genesis.maxLovelaceSupply));
  if (protocolParameters) return cache.get('protocolParameters', () => getProtocolParameters(db));
  if (stake) return cache.get('stake', () => getStake(cardanoNode, db));

  return Promise.reject(new Error(`Unknown request ${NJSON.stringify(request)}`));
};
