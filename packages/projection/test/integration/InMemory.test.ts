import * as Crypto from '@cardano-sdk/crypto';
import {
  Bootstrap,
  BootstrapExtraProps,
  InMemory,
  Operators,
  ProjectionEvent,
  ProjectionOperator,
  RollForwardEvent
} from '../../src';
import { Cardano, CardanoNodeErrors, ChainSyncEventType, ChainSyncRollForward } from '@cardano-sdk/core';
import { ChainSyncDataSet, StubChainSyncData, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { from, lastValueFrom, of, toArray } from 'rxjs';

const dataWithPoolRetirement = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
const dataWithStakeKeyDeregistration = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);

const projectStakeKeys: ProjectionOperator<Operators.WithCertificates & InMemory.WithInMemoryStore> = (evt$) =>
  evt$.pipe(Operators.withStakeKeys(), InMemory.storeStakeKeys());
const projectStakePools: ProjectionOperator<Operators.WithCertificates & InMemory.WithInMemoryStore> = (evt$) =>
  evt$.pipe(Operators.withStakePools(), InMemory.storeStakePools());

describe('integration/InMemory', () => {
  let store: InMemory.InMemoryStore;
  let buffer: InMemory.InMemoryStabilityWindowBuffer;

  const projectAll = (
    { cardanoNode }: StubChainSyncData,
    projection: ProjectionOperator<Operators.WithCertificates & InMemory.WithInMemoryStore>
  ) =>
    lastValueFrom(
      Bootstrap.fromCardanoNode({ buffer, cardanoNode, logger }).pipe(
        Operators.withStaticContext({ store }),
        Operators.withCertificates(),
        projection,
        buffer.handleEvents(),
        Operators.requestNext(),
        toArray()
      )
    );

  beforeEach(() => {
    store = { stakeKeys: new Set(), stakePools: new Map() };
    buffer = new InMemory.InMemoryStabilityWindowBuffer();
  });

  describe('from origin', () => {
    it('projects stakePools', async () => {
      await projectAll(dataWithPoolRetirement, projectStakePools);
      expect(store.stakePools.size).toBe(3);
      expect(
        store.stakePools.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'))!.updates
      ).toHaveLength(2);
      expect(
        store.stakePools.get(Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q'))!.retirements
      ).toHaveLength(2);
    });

    it('projects stakeKeys', async () => {
      await projectAll(dataWithStakeKeyDeregistration, projectStakeKeys);
      expect(store.stakeKeys).toEqual(
        new Set([Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857b')])
      );
    });
  });

  it('resumes from specific block', async () => {
    buffer
      .handleEvents()(
        of({
          ...dataWithPoolRetirement.allEvents.find(
            (evt): evt is ChainSyncRollForward =>
              evt.eventType === ChainSyncEventType.RollForward && evt.block.header.blockNo === Cardano.BlockNo(32_209)
          )!,
          ...dataWithPoolRetirement.networkInfo
        } as ProjectionEvent<{}>)
      )
      .subscribe();
    const [firstBlock] = await projectAll(dataWithPoolRetirement, projectStakePools);
    expect(firstBlock.block.header.blockNo).toBe(32_210);
    expect(
      store.stakePools.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'))!.updates
    ).toHaveLength(1);
  });

  it('resuming from a fork rolls back and continues from intersection', async () => {
    const rolledBackKey = Crypto.Ed25519KeyHashHex('3b62970858d61cf667701c1f34abef41659516b191d7d374e8b0857c');
    store.stakeKeys.add(rolledBackKey);
    buffer
      .handleEvents()(
        from([
          // Tail
          {
            block: {
              header: {
                blockNo: Cardano.BlockNo(22_620),
                hash: Cardano.BlockId('786f9ca474cc0db3ccbd35fec7ce69835a0a58b2d954db07102768033869b0f2'),
                slot: Cardano.Slot(687_927)
              }
            },
            eventType: ChainSyncEventType.RollForward,
            ...dataWithStakeKeyDeregistration.networkInfo
          } as RollForwardEvent<BootstrapExtraProps>,
          // Intersection
          {
            block: {
              header: {
                blockNo: Cardano.BlockNo(22_621),
                hash: Cardano.BlockId('c75e9fdb8c24caf2e8d10d1a066c1157572c4ce769378d6708ff2e0aa87ba2db'),
                slot: Cardano.Slot(687_935)
              }
            },
            eventType: ChainSyncEventType.RollForward,
            ...dataWithStakeKeyDeregistration.networkInfo
          } as RollForwardEvent<BootstrapExtraProps>,
          // To be rolled back
          {
            block: {
              body: [
                {
                  body: {
                    certificates: [
                      { __typename: Cardano.CertificateType.StakeKeyRegistration, stakeKeyHash: rolledBackKey }
                    ]
                  }
                } as Cardano.Tx
              ],
              header: {
                blockNo: Cardano.BlockNo(22_622),
                hash: Cardano.BlockId('c75e9fdb8c24caf2e8d10d1a066c1157572c4ce769378d6708ff2e0aa87ba2de'),
                slot: Cardano.Slot(688_935)
              }
            },
            eventType: ChainSyncEventType.RollForward,
            ...dataWithStakeKeyDeregistration.networkInfo
          } as RollForwardEvent<BootstrapExtraProps>
        ])
      )
      .subscribe();
    const [firstBlock] = await projectAll(dataWithStakeKeyDeregistration, projectStakeKeys);
    expect(firstBlock.block.header.blockNo).toBe(22_622);
    expect(firstBlock.crossEpochBoundary).toBe(false);
    expect(store.stakeKeys.size).toBe(1);
  });

  it('errors with a buffer from another network', async () => {
    buffer
      .handleEvents()(
        // No intersection, both block hashes are not present in the dataset
        from([
          {
            block: {
              header: {
                blockNo: Cardano.BlockNo(22_621),
                hash: Cardano.BlockId('c75e9fdb8c24caf2e8d10d1a066c1157572c4ce769378d6708ff2e0aa87ba2de'),
                slot: Cardano.Slot(687_935)
              }
            },
            eventType: ChainSyncEventType.RollForward,
            ...dataWithStakeKeyDeregistration.networkInfo
          } as RollForwardEvent<BootstrapExtraProps>,
          {
            block: {
              header: {
                blockNo: Cardano.BlockNo(22_622),
                hash: Cardano.BlockId('c75e9fdb8c24caf2e8d10d1a066c1157572c4ce769378d6708ff2e0aa87ba2df'),
                slot: Cardano.Slot(688_935)
              }
            },
            eventType: ChainSyncEventType.RollForward,
            ...dataWithStakeKeyDeregistration.networkInfo
          } as RollForwardEvent<BootstrapExtraProps>
        ])
      )
      .subscribe();
    await expect(projectAll(dataWithStakeKeyDeregistration, projectStakeKeys)).rejects.toThrowError(
      CardanoNodeErrors.CardanoClientErrors.IntersectionNotFoundError
    );
  });
});
