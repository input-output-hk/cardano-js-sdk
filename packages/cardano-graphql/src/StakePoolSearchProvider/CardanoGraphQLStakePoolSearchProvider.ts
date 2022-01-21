import { Cardano, StakePoolSearchProvider, util } from '@cardano-sdk/core';
import { createProvider, getExactlyOneObject, graphqlPoolParametersToCore } from '../util';
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
  const responsePoolParameters = util.replaceNullsWithUndefineds(
    getExactlyOneObject(responseStakePool.poolParameters, 'PoolParameters')
  );
  const poolParameters = graphqlPoolParametersToCore(responsePoolParameters, responseStakePool.id);
  return {
    ...poolParameters,
    hexId: Cardano.PoolIdHex(stakePool.hexId),
    metadata: responsePoolParameters.metadata
      ? {
          ...responsePoolParameters.metadata,
          ext: responsePoolParameters.metadata.ext
            ? {
                ...responsePoolParameters.metadata.ext,
                pool: {
                  ...responsePoolParameters.metadata.ext.pool,
                  id: Cardano.PoolIdHex(responsePoolParameters.metadata.ext.pool.id)
                }
              }
            : undefined,
          extVkey: responsePoolParameters.metadata.extVkey
            ? Cardano.PoolMdVk(responsePoolParameters.metadata.extVkey)
            : undefined
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
    status: stakePool.status,
    transactions: {
      // TODO: current implementation will only return 1 (latest/active) registration certificate
      // We should probably change this core type to include epoch when it takes effect
      registration: [certificateTxHash(responsePoolParameters.poolRegistrationCertificate)],
      retirement: certificateTxHashes(stakePool.poolRetirementCertificates)
    }
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
