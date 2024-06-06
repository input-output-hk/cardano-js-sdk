import {
  AddressEntity,
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  NftMetadataEntity,
  OutputEntity,
  StakeKeyRegistrationEntity,
  TokensEntity,
  createObservableConnection,
  storeAddresses,
  storeAssets,
  storeBlock,
  storeStakeKeyRegistrations,
  storeUtxo,
  typeormTransactionCommit,
  willStoreAddresses,
  withTypeormTransaction
} from '../../src/index.js';
import { Bootstrap, Mappers, requestNext } from '@cardano-sdk/projection';
import { Cardano } from '@cardano-sdk/core';
import {
  ChainSyncDataSet,
  chainSyncData,
  cip19TestVectors,
  generateRandomHexString,
  logger
} from '@cardano-sdk/util-dev';
import { connectionConfig$, initializeDataSource } from '../util.js';
import {
  createProjectorContext,
  createProjectorTilFirst,
  createRollForwardEventBasedOn,
  createStubBlockHeader,
  createStubProjectionSource,
  createStubRollForwardEvent
} from './util.js';
import { firstValueFrom } from 'rxjs';
import type { Address } from '@cardano-sdk/projection/dist/cjs/operators/Mappers';
import type { Observable } from 'rxjs';
import type { ProjectionEvent } from '@cardano-sdk/projection';
import type { QueryRunner, Repository } from 'typeorm';
import type { TypeormStabilityWindowBuffer, TypeormTipTracker } from '../../src/index.js';

const isAddressWithBothCredentials = (addr: Mappers.Address) =>
  typeof addr.stakeCredential === 'string' && !!addr.paymentCredentialHash;

describe('storeAddresses', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;
  const entities = [
    BlockEntity,
    BlockDataEntity,
    AssetEntity,
    NftMetadataEntity,
    TokensEntity,
    OutputEntity,
    StakeKeyRegistrationEntity,
    AddressEntity
  ];
  let addressesRepo: Repository<AddressEntity>;

  const storeData = (
    evt$: Observable<
      ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint & Mappers.WithStakeKeyRegistrations & Mappers.WithAddresses>
    >
  ) =>
    evt$.pipe(
      withTypeormTransaction({ connection$: createObservableConnection({ connectionConfig$, entities, logger }) }),
      storeBlock(),
      storeAssets(),
      storeUtxo(),
      storeStakeKeyRegistrations(),
      storeAddresses(),
      buffer.storeBlockData(),
      typeormTransactionCommit()
    );

  const applyOperators = (evt$: Observable<ProjectionEvent<{}>>) =>
    evt$.pipe(
      Mappers.withMint(),
      Mappers.withUtxo(),
      Mappers.withCertificates(),
      Mappers.withStakeKeyRegistrations(),
      Mappers.withAddresses(),
      storeData,
      tipTracker.trackProjectedTip(),
      requestNext()
    );

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 1,
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(applyOperators);

  const projectTilFirst = createProjectorTilFirst(project$);

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    addressesRepo = queryRunner.manager.getRepository(AddressEntity);
    ({ buffer, tipTracker } = createProjectorContext(entities));
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  it('inserts addresses with their type, payment credential and stake credential', async () => {
    const { addresses } = await projectTilFirst((evt) => evt.addresses.some(isAddressWithBothCredentials));
    const { address, type, paymentCredentialHash, stakeCredential } = addresses.find(isAddressWithBothCredentials)!;
    const projectedAddress = await addressesRepo.findOne({ where: { address } })!;
    expect(projectedAddress).toEqual({
      address,
      paymentCredentialHash,
      stakeCredentialHash: stakeCredential,
      type
    });
  });

  describe('pointer addresses', () => {
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const projectEvtWithAddress = (address: Cardano.PaymentAddress, blockNo: Cardano.BlockNo) =>
      firstValueFrom(
        // clone the same block, just bump/patch the header
        createStubProjectionSource([
          createStubRollForwardEvent(
            {
              blockBody: [
                {
                  body: {
                    fee: 123n,
                    inputs: [],
                    outputs: [
                      {
                        address,
                        value: {
                          coins: 123n
                        }
                      }
                    ]
                  },
                  id: Cardano.TransactionId(generateRandomHexString(64)),
                  inputSource: Cardano.InputSource.inputs,
                  witness: { signatures: new Map() }
                }
              ],
              blockHeader: createStubBlockHeader(blockNo)
            },
            stubEvents.networkInfo
          )
        ]).pipe(applyOperators)
      );

    it('looks up stake key hash by pointer', async () => {
      const stakeKeyRegistrationEvent = await projectTilFirst((evt) => evt.stakeKeyRegistrations.length > 0);
      const registration = stakeKeyRegistrationEvent.stakeKeyRegistrations[0];
      const address = Cardano.PointerAddress.fromCredentials(
        Cardano.NetworkId.Testnet,
        cip19TestVectors.KEY_PAYMENT_CREDENTIAL,
        registration.pointer
      )
        .toAddress()
        .toBech32() as Cardano.PaymentAddress;
      await projectEvtWithAddress(address, Cardano.BlockNo(stakeKeyRegistrationEvent.block.header.blockNo + 1));
      const projectedAddress = await addressesRepo.findOne({ where: { address } });
      expect(typeof projectedAddress!.stakeCredentialHash).toBe('string');
    });

    it('projects null pointers as undefined stake credential', async () => {
      const address = Cardano.PointerAddress.fromCredentials(
        Cardano.NetworkId.Testnet,
        cip19TestVectors.KEY_PAYMENT_CREDENTIAL,
        cip19TestVectors.POINTER
      )
        .toAddress()
        .toBech32() as Cardano.PaymentAddress;
      await projectEvtWithAddress(address, Cardano.BlockNo(0));
      const projectedAddress = await addressesRepo.findOne({ where: { address } });
      expect(projectedAddress).not.toBeNull();
      expect(projectedAddress!.stakeCredentialHash).toBeNull();
    });
  });

  it('is idempotent', async () => {
    const evt = await projectTilFirst(({ addresses }) => addresses.some(isAddressWithBothCredentials));
    await expect(
      firstValueFrom(
        // clone the same block, just bump/patch the header
        createStubProjectionSource([createRollForwardEventBasedOn(evt, (block) => block)]).pipe(applyOperators)
      )
    ).resolves.not.toThrow();
  });
});

describe('willStoreAddresses', () => {
  it('returns true if address are bigger than 1', () => {
    expect(
      willStoreAddresses({
        addresses: [{} as Address]
      })
    ).toBeTruthy();
  });

  it('returns false if there are no addresses', () => {
    expect(
      willStoreAddresses({
        addresses: []
      })
    ).toBeFalsy();
  });
});
