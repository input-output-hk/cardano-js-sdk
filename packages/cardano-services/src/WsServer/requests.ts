import { Cardano, CardanoNode, CardanoNodeUtil } from '@cardano-sdk/core';
import { Pool } from 'pg';
import { ProtocolParamsModel } from '../NetworkInfo/DbSyncNetworkInfoProvider/types';
import { toProtocolParams } from '../NetworkInfo/DbSyncNetworkInfoProvider/mappers';

export const getLovelaceSupply = async (db: Pool, maxLovelaceSupply: Cardano.Lovelace) => {
  const query = 'SELECT utxo + rewards AS circulating, reserves FROM ada_pots ORDER BY id DESC LIMIT 1';
  const { rows } = await db.query<{ circulating: string; reserves: string }>(query);
  const [row] = rows;

  // Workaround to make this work on epoch 0 as well.
  // Once db-sync will solve this problem the "no lines found" case can be removed.
  return row
    ? { circulating: BigInt(row.circulating), total: maxLovelaceSupply - BigInt(row.reserves) }
    : { circulating: 0n, total: maxLovelaceSupply };
};

// committee_term_limit min_committee_size
export const getProtocolParameters = async (db: Pool) => {
  const query = `\
SELECT epoch_param.*, cost_model.costs FROM epoch_param
  LEFT JOIN cost_model ON cost_model.id = epoch_param.cost_model_id
  ORDER BY epoch_no DESC NULLS LAST LIMIT 1`;
  const { rows } = await db.query<ProtocolParamsModel>(query);

  return toProtocolParams(rows[0]);
};

export const getStake = async (cardanoNode: CardanoNode, db: Pool) => {
  const [live, active] = await Promise.all([
    cardanoNode.stakeDistribution().then(CardanoNodeUtil.toLiveStake),
    (async () => {
      const { rows } = await db.query<{ stake: string }>(
        'SELECT COALESCE(SUM(amount), 0) AS stake FROM epoch_stake WHERE epoch_no = (SELECT MAX(no) FROM epoch) - 1'
      );

      return BigInt(rows[0].stake);
    })()
  ]);

  return { active, live };
};
