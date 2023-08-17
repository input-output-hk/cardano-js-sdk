import {
  AddressEntity,
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  NftMetadataEntity,
  OutputEntity,
  StakeKeyRegistrationEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  storeAddresses,
  storeAssets,
  storeBlock,
  storeStakeKeyRegistrations,
  storeUtxo,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano } from '@cardano-sdk/core';
import {
  ChainSyncDataSet,
  chainSyncData,
  cip19TestVectors,
  generateRandomHexString,
  logger
} from '@cardano-sdk/util-dev';
import { Observable, defer, firstValueFrom, from } from 'rxjs';
import { QueryRunner, Repository } from 'typeorm';
import {
  createProjectorTilFirst,
  createRollForwardEventBasedOn,
  createStubBlockHeader,
  createStubProjectionSource,
  createStubRollForwardEvent
} from './util';
import { initializeDataSource } from '../util';

const isAddressWithBothCredentials = (addr: Mappers.Address) =>
  typeof addr.stakeCredential === 'string' && !!addr.paymentCredentialHash;

describe('storeAddresses', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
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

  const dataSource$ = defer(() =>
    from(initializeDataSource({ devOptions: { dropSchema: false, synchronize: false }, entities }))
  );

  const storeData = (
    evt$: Observable<
      ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint & Mappers.WithStakeKeyRegistrations & Mappers.WithAddresses>
    >
  ) =>
    evt$.pipe(
      withTypeormTransaction({ dataSource$, logger }),
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
      requestNext()
    );

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 1,
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger
    }).pipe(applyOperators);

  const projectTilFirst = createProjectorTilFirst(project$);

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    addressesRepo = queryRunner.manager.getRepository(AddressEntity);
    buffer = new TypeormStabilityWindowBuffer({ allowNonSequentialBlockHeights: true, logger });
    await buffer.initialize(queryRunner);
  });

  afterEach(async () => {
    await queryRunner.release();
    buffer.shutdown();
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
