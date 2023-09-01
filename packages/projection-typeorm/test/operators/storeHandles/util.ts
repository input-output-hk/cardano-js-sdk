import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  HandleEntity,
  NftMetadataEntity,
  OutputEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  storeAssets,
  storeBlock,
  storeHandles,
  storeUtxo,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../../src';
import { Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger, mockProviders } from '@cardano-sdk/util-dev';
import { Observable, defer, from } from 'rxjs';
import { createProjectorTilFirst, createStubProjectionSource } from '../util';
import { initializeDataSource } from '../../util';

export const stubEvents = chainSyncData(ChainSyncDataSet.WithHandle);
export const policyId = Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a');
export const policyIds = [policyId];

const blockHeader = {
  blockNo: Cardano.BlockNo(317_881),
  hash: Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000'),
  slot: Cardano.Slot(13_633_737)
};
export const createMultiTxProjectionSource = (txs: Pick<Cardano.OnChainTx, 'id' | 'body'>[]) =>
  createStubProjectionSource([
    {
      block: {
        body: txs.map((tx) => ({
          ...tx,
          inputSource: Cardano.InputSource.inputs,
          witness: { signatures: new Map() }
        })),
        header: blockHeader,
        totalOutput: 123n,
        txCount: txs.length
      },
      crossEpochBoundary: false,
      epochNo: Cardano.EpochNo(31),
      eraSummaries: [],
      eventType: ChainSyncEventType.RollForward,
      genesisParameters: mockProviders.genesisParameters,
      tip: blockHeader
    }
  ]);

export const entities = [
  BlockEntity,
  BlockDataEntity,
  AssetEntity,
  TokensEntity,
  OutputEntity,
  HandleEntity,
  NftMetadataEntity
];

const dataSource$ = defer(() =>
  from(initializeDataSource({ devOptions: { dropSchema: false, synchronize: false }, entities }))
);

const storeData =
  (buffer: TypeormStabilityWindowBuffer) =>
  (evt$: Observable<ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint & Mappers.WithHandles>>) =>
    evt$.pipe(
      withTypeormTransaction({ dataSource$, logger }),
      storeBlock(),
      storeAssets(),
      storeUtxo(),
      storeHandles(),
      buffer.storeBlockData(),
      typeormTransactionCommit()
    );

// eslint-disable-next-line unicorn/consistent-function-scoping
export const applyOperators = (buffer: TypeormStabilityWindowBuffer) => (evt$: Observable<ProjectionEvent<{}>>) =>
  evt$.pipe(
    Mappers.withUtxo(),
    Mappers.withMint(),
    Mappers.filterProducedUtxoByAssetPolicyId({ policyIds }),
    Mappers.filterMintByPolicyIds({ policyIds }),
    Mappers.withCIP67(),
    Mappers.withHandles({ policyIds }, logger),
    storeData(buffer),
    requestNext()
  );

export const project$ = (buffer: TypeormStabilityWindowBuffer) => () =>
  Bootstrap.fromCardanoNode({ blocksBufferLength: 10, buffer, cardanoNode: stubEvents.cardanoNode, logger }).pipe(
    applyOperators(buffer)
  );

export const projectTilFirst = (buffer: TypeormStabilityWindowBuffer) => createProjectorTilFirst(project$(buffer));
