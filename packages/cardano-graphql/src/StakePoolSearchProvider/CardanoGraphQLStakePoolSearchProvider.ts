import { Cardano, StakePoolSearchProvider, util } from '@cardano-sdk/core';
import { createProvider, getExactlyOneObject } from '../util';
import { getSdk } from '../sdk';
import { sortBy } from 'lodash-es';

type Awaited<T> = T extends PromiseLike<infer U> ? U : T;
type GraphqlStakePool = NonNullable<
  NonNullable<Awaited<ReturnType<ReturnType<typeof getSdk>['StakePoolsByMetadata']>>['queryStakePoolMetadata']>[0]
>['poolParameters']['stakePool'];

const certificateTxHash = ({ transaction: { hash } }: { transaction: { hash: string } }) => Cardano.TransactionId(hash);
const certificateTxHashes = (certificates: Array<{ transaction: { hash: string; block: { blockNo: number } } }>) =>
  sortBy(
    certificates,
    ({
      transaction: {
        block: { blockNo }
      }
    }) => blockNo
  ).map(certificateTxHash);

const toCoreStakePool = (responseStakePool: GraphqlStakePool): Cardano.StakePool => {
  const stakePool = util.replaceNullsWithUndefineds(responseStakePool);
  const poolParameters = getExactlyOneObject(stakePool.poolParameters, 'PoolParameters');
  return {
    cost: BigInt(poolParameters.cost),
    hexId: Cardano.PoolIdHex(stakePool.hexId),
    id: Cardano.PoolId(stakePool.id),
    margin: poolParameters.margin,
    metadata: poolParameters.metadata
      ? {
          ...poolParameters.metadata,
          ext: poolParameters.metadata.ext
            ? {
                ...poolParameters.metadata.ext,
                pool: {
                  ...poolParameters.metadata.ext.pool,
                  id: Cardano.PoolIdHex(poolParameters.metadata.ext.pool.id)
                }
              }
            : undefined,
          extVkey: poolParameters.metadata.extVkey ? Cardano.PoolMdVk(poolParameters.metadata.extVkey) : undefined
        }
      : undefined,
    metadataJson: poolParameters.metadataJson
      ? {
          ...poolParameters.metadataJson,
          hash: Cardano.Hash32ByteBase16(poolParameters.metadataJson.hash)
        }
      : undefined,
    metrics: {
      ...stakePool.metrics!,
      livePledge: BigInt(stakePool.metrics.livePledge),
      stake: {
        active: BigInt(stakePool.metrics.stake.active),
        live: BigInt(stakePool.metrics.stake.live)
      }
    },
    owners: poolParameters.owners.map(({ address }) => Cardano.RewardAccount(address)),
    pledge: BigInt(poolParameters.pledge),
    relays: poolParameters.relays,
    rewardAccount: Cardano.RewardAccount(poolParameters.rewardAccount.address),
    status: stakePool.status,
    transactions: {
      // TODO: current implementation will only return 1 (latest/active) registration certificate
      // We should probably change this core type to include epoch when it takes effect
      registration: [certificateTxHash(poolParameters.poolRegistrationCertificate)],
      retirement: certificateTxHashes(stakePool.poolRetirementCertificates)
    },
    vrf: Cardano.VrfVkHex(poolParameters.vrf)
  };
};

export const createGraphQLStakePoolSearchProvider = createProvider<StakePoolSearchProvider>((sdk) => ({
  async queryStakePools(fragments: string[]): Promise<Cardano.StakePool[]> {
    const query = fragments.join(' ');
    const byStakePoolFields = (await sdk.StakePools({ query })).queryStakePool?.filter(util.isNotNil);
    const byMetadataFields = await sdk.StakePoolsByMetadata({
      omit: byStakePoolFields?.length ? byStakePoolFields?.map((sp) => sp.id) : undefined,
      query
    });
    const responseStakePools = [
      ...(byStakePoolFields || []),
      ...(byMetadataFields.queryStakePoolMetadata || []).map((sp) => sp?.poolParameters.stakePool)
    ].filter(util.isNotNil);
    return responseStakePools.map(toCoreStakePool);
  }
}));
