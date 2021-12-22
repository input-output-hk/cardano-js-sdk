import { Cardano, util } from '@cardano-sdk/core';
import { StakePoolsQuery } from '../sdk';

export type GraphqlStakePool = NonNullable<NonNullable<StakePoolsQuery['queryStakePool']>[0]>;
export type ResponsePoolParameters = NonNullable<GraphqlStakePool['poolParameters'][0]>;

export const graphqlPoolParametersToCore = (
  poolParameters: ResponsePoolParameters,
  poolId: string
): Cardano.PoolParameters => ({
  cost: BigInt(poolParameters.cost),
  id: Cardano.PoolId(poolId),
  margin: poolParameters.margin,
  metadata: poolParameters.metadata
    ? (() => {
        const metadata = util.replaceNullsWithUndefineds(poolParameters.metadata);
        return {
          ...metadata,
          ext: metadata.ext
            ? {
                ...metadata.ext,
                pool: { ...metadata.ext.pool, id: Cardano.PoolIdHex(metadata.ext.pool.id) }
              }
            : undefined,
          extVkey: metadata.extVkey ? Cardano.PoolMdVk(metadata.extVkey) : undefined
        };
      })()
    : undefined,
  metadataJson: poolParameters.metadataJson
    ? {
        ...poolParameters.metadataJson,
        hash: Cardano.Hash32ByteBase16(poolParameters.metadataJson.hash)
      }
    : undefined,
  owners: poolParameters.owners.map(({ address }) => Cardano.RewardAccount(address)),
  pledge: BigInt(poolParameters.pledge),
  relays: poolParameters.relays.map(util.replaceNullsWithUndefineds),
  rewardAccount: Cardano.RewardAccount(poolParameters.rewardAccount.address),
  vrf: Cardano.VrfVkHex(poolParameters.vrf)
});
