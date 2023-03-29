import * as Crypto from '@cardano-sdk/crypto';
import {
  Bootstrap,
  InMemory,
  RollForwardEvent,
  Sink,
  StabilityWindowBuffer,
  UnifiedProjectorEvent,
  projectIntoSink
} from '../src';
import { Cardano, CardanoNodeErrors, ChainSyncEventType, ChainSyncRollForward } from '@cardano-sdk/core';
import { ChainSyncDataSet, StubChainSyncData, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { DefaultProjectionProps, allProjections } from '../src/projections';
import { InMemoryStabilityWindowBuffer } from '../src/sinks/inMemory';
import { from, lastValueFrom, of, toArray } from 'rxjs';
import pick from 'lodash/pick';

const dataWithPoolRetirement = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
const dataWithStakeKeyDeregistration = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);

const projections = pick(allProjections, ['stakePools', 'stakeKeys']);

const projectAll = (
  { cardanoNode }: StubChainSyncData,
  buffer: StabilityWindowBuffer,
  sink: Sink<typeof projections>
) =>
  lastValueFrom(
    Bootstrap.fromCardanoNode({ buffer, cardanoNode, logger }).pipe(
      projectIntoSink({
        projections,
        sink
      }),
      toArray()
    )
  );

describe('projectIntoSink', () => {
  let store: InMemory.InMemoryStore;
  let sink: Sink<InMemory.SupportedProjections>;
  let buffer: InMemory.InMemoryStabilityWindowBuffer;

  beforeEach(() => {
    store = { stakeKeys: new Set(), stakePools: new Map() };
    buffer = new InMemoryStabilityWindowBuffer();
    sink = InMemory.createSink(store, buffer);
  });

  describe('from origin', () => {
    it('projects stakePools', async () => {
      await projectAll(dataWithPoolRetirement, buffer, sink);
      expect(store.stakePools.size).toBe(3);
      expect(
        store.stakePools.get(Cardano.PoolId('pool1n3s8unkvmre59uzt4ned0903f9q2p8dhscw5v9eeyc0sw0m439t'))!.updates
      ).toHaveLength(2);
      expect(
        store.stakePools.get(Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q'))!.retirements
      ).toHaveLength(2);
    });

    it('projects stakeKeys', async () => {
      await projectAll(dataWithStakeKeyDeregistration, buffer, sink);
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
        } as UnifiedProjectorEvent<DefaultProjectionProps>)
      )
      .subscribe();
    const [firstBlock] = await projectAll(dataWithPoolRetirement, buffer, sink);
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
          } as RollForwardEvent<DefaultProjectionProps>,
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
          } as RollForwardEvent<DefaultProjectionProps>,
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
          } as RollForwardEvent<DefaultProjectionProps>
        ])
      )
      .subscribe();
    const [firstBlock] = await projectAll(dataWithStakeKeyDeregistration, buffer, sink);
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
          } as RollForwardEvent<DefaultProjectionProps>,
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
          } as RollForwardEvent<DefaultProjectionProps>
        ])
      )
      .subscribe();
    await expect(projectAll(dataWithStakeKeyDeregistration, buffer, sink)).rejects.toThrowError(
      CardanoNodeErrors.CardanoClientErrors.IntersectionNotFoundError
    );
  });

  it('can be used with a subset of available projections', async () => {
    const subsetOfProjections = pick(allProjections, ['stakeKeys']);
    await lastValueFrom(
      Bootstrap.fromCardanoNode({
        buffer,
        cardanoNode: dataWithPoolRetirement.cardanoNode,
        logger
      }).pipe(
        projectIntoSink({
          projections: subsetOfProjections,
          sink
        }),
        toArray()
      )
    );
    expect(store.stakeKeys.size).toBeGreaterThan(0);
    expect(store.stakePools.size).toBe(0);
  });
});
