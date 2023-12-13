import { AddressEntity, AssetEntity, BlockEntity, HandleEntity, HandleMetadataEntity } from '../../../src';
import { Cardano, Handle, util } from '@cardano-sdk/core';
import {
  DefaultHandleParamsQueryResponse,
  queryHandlesByAddressCredentials,
  sortHandles
} from '../../../src/operators/storeHandles';
import {
  ProjectorContext,
  createProjectorContext,
  createStubBlockHeader,
  createStubProjectionSource,
  createStubRollForwardEvent,
  createStubTx
} from '../util';
import { QueryRunner, Repository } from 'typeorm';
import { cip19TestVectors, generateRandomHexString } from '@cardano-sdk/util-dev';
import { entities, mapAndStore, policyId, projectTilFirst, stubEvents } from './util';
import { firstValueFrom } from 'rxjs';
import { initializeDataSource } from '../../util';

describe('storeHandles', () => {
  let queryRunner: QueryRunner;
  let context: ProjectorContext;
  let handleRepository: Repository<HandleEntity>;

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    context = createProjectorContext(entities);
    handleRepository = queryRunner.manager.getRepository(HandleEntity);
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  const mintFirstHandle = async () => {
    const firstHandleEvent = await projectTilFirst(context)((evt) => evt.handles.length > 0);
    const firstHandle = firstHandleEvent.handles[0];
    const firstHandleStored = await handleRepository.findOneOrFail({ where: { handle: firstHandle.handle } })!;
    return { firstHandle, firstHandleEvent, firstHandleStored };
  };

  const mintHandle = async (
    ownerAddress: Cardano.PaymentAddress,
    og: boolean,
    length: number,
    currentTip: Cardano.BlockNo
  ) => {
    const ogHandleAssetName = Cardano.AssetName(
      util.utf8ToHex(
        // Longer than first handle
        Array.from({ length })
          .map((_, i) => i)
          .join('')
      )
    );
    const ogHandleAssetId = Cardano.AssetId.fromParts(policyId, ogHandleAssetName);
    const ogHandleTokenMap = new Map([[ogHandleAssetId, 1n]]);
    const createOgHandle = createStubRollForwardEvent(
      {
        blockBody: [
          createStubTx(
            {
              mint: ogHandleTokenMap,
              outputs: [
                {
                  address: ownerAddress,
                  value: {
                    assets: ogHandleTokenMap,
                    coins: 123n
                  }
                }
              ]
            },
            new Map<bigint, Cardano.Metadatum>([
              [
                721n,
                new Map([
                  [
                    policyId,
                    new Map([
                      [
                        ogHandleAssetName,
                        new Map<Cardano.Metadatum, Cardano.Metadatum>([
                          ['name', '$og'],
                          ['image', 'https://og.image'],
                          ['core', new Map([['og', og ? 1n : 0n]])]
                        ])
                      ]
                    ])
                  ]
                ])
              ]
            ])
          )
        ],
        blockHeader: createStubBlockHeader(Cardano.BlockNo(currentTip + 1))
      },
      stubEvents.networkInfo
    );

    const event = await firstValueFrom(createStubProjectionSource([createOgHandle]).pipe(mapAndStore(context)));
    const handleOwnership = event.handles[0];
    const storedHandle = await handleRepository.findOneOrFail({ where: { handle: handleOwnership.handle } })!;
    return { event, handleOwnership, storedHandle };
  };

  describe('sortHandles', () => {
    it('returns 0 or 1 handles array unchanged', () => {
      const oneHandle = [{ firstMintSlot: Cardano.Slot(1), handle: 'bob', og: false }];
      expect(sortHandles([])).toEqual([]);
      expect(sortHandles(oneHandle)).toBe(oneHandle);
    });

    it('sorts by og->length->age->alphabetical', () => {
      expect(
        sortHandles([
          {
            firstMintSlot: Cardano.Slot(8),
            handle: '1234566',
            og: false
          },
          {
            firstMintSlot: Cardano.Slot(9),
            handle: '12345',
            og: false
          },
          {
            firstMintSlot: Cardano.Slot(8),
            handle: '1234567',
            og: false
          },
          {
            firstMintSlot: Cardano.Slot(9),
            handle: '123456',
            og: false
          },
          {
            firstMintSlot: Cardano.Slot(9),
            handle: '123456789',
            og: true
          },
          {
            firstMintSlot: Cardano.Slot(9),
            handle: '12345678',
            og: true
          }
        ]).map(({ handle }) => handle)
      ).toEqual(['12345678', '123456789', '12345', '123456', '1234566', '1234567']);
    });
  });

  describe('queryHandlesByAddressCredentials', () => {
    const block: BlockEntity = {
      hash: Cardano.BlockId(generateRandomHexString(64)),
      height: Cardano.BlockNo(1),
      slot: Cardano.Slot(20)
    };

    const insertHandleAsset = async (assetRepo: Repository<AssetEntity>, handle: Handle) =>
      assetRepo.save({
        firstMintBlock: block,
        id: Cardano.AssetId.fromParts(policyId, Cardano.AssetName(Buffer.from(handle, 'utf8').toString('hex'))),
        supply: 1n
      });

    const createHandle = async (
      handle: Handle,
      cardanoAddress: Cardano.PaymentAddress,
      assetRepo: Repository<AssetEntity>
    ) => ({
      asset: await insertHandleAsset(assetRepo, handle),
      cardanoAddress,
      defaultForPaymentCredential: 'samestake',
      defaultForStakeCredential: 'samestake',
      handle,
      hasDatum: false,
      policyId
    });

    const createHandleMetadata = (handle: Handle, og: boolean): HandleMetadataEntity => ({
      block: { slot: Cardano.Slot(20) },
      handle,
      og
    });

    beforeEach(async () => {
      const addressRepo = queryRunner.manager.getRepository(AddressEntity);
      const blockRepo = queryRunner.manager.getRepository(BlockEntity);
      const assetRepo = queryRunner.manager.getRepository(AssetEntity);
      const handleRepo = queryRunner.manager.getRepository(HandleEntity);
      const handleMetadataRepo = queryRunner.manager.getRepository(HandleMetadataEntity);

      await blockRepo.insert(block);

      // using cip19TestVectors 'script' addresses for non-matching,
      // and 'key' addresses for matching.
      await addressRepo.insert([
        {
          address: cip19TestVectors.basePaymentKeyStakeKey,
          paymentCredentialHash: cip19TestVectors.PAYMENT_KEY_HASH,
          stakeCredentialHash: cip19TestVectors.STAKE_KEY_HASH,
          type: Cardano.AddressType.BasePaymentKeyStakeKey
        },
        {
          address: cip19TestVectors.enterpriseKey,
          paymentCredentialHash: cip19TestVectors.PAYMENT_KEY_HASH,
          type: Cardano.AddressType.EnterpriseKey
        },
        {
          address: cip19TestVectors.basePaymentKeyStakeScript,
          paymentCredentialHash: cip19TestVectors.PAYMENT_KEY_HASH,
          stakeCredentialHash: cip19TestVectors.SCRIPT_HASH,
          type: Cardano.AddressType.BasePaymentKeyStakeScript
        },
        {
          address: cip19TestVectors.basePaymentScriptStakeKey,
          paymentCredentialHash: cip19TestVectors.SCRIPT_HASH,
          stakeCredentialHash: cip19TestVectors.STAKE_KEY_HASH,
          type: Cardano.AddressType.BasePaymentScriptStakeKey
        },
        {
          address: cip19TestVectors.basePaymentScriptStakeScript,
          paymentCredentialHash: cip19TestVectors.SCRIPT_HASH,
          stakeCredentialHash: cip19TestVectors.SCRIPT_HASH,
          type: Cardano.AddressType.BasePaymentScriptStakeScript
        },
        {
          address: cip19TestVectors.enterpriseScript,
          paymentCredentialHash: cip19TestVectors.SCRIPT_HASH,
          type: Cardano.AddressType.EnterpriseScript
        }
      ] as AddressEntity[]);

      await handleRepo.save([
        await createHandle('sameaddress', cip19TestVectors.basePaymentKeyStakeKey, assetRepo),
        await createHandle('samepayment', cip19TestVectors.basePaymentKeyStakeScript, assetRepo),
        await createHandle('samepayment2', cip19TestVectors.basePaymentKeyStakeScript, assetRepo),
        await createHandle('samepaymententerprise', cip19TestVectors.enterpriseKey, assetRepo),
        await createHandle('samestake', cip19TestVectors.basePaymentScriptStakeKey, assetRepo),
        await createHandle('nonmatching', cip19TestVectors.basePaymentScriptStakeScript, assetRepo),
        await createHandle('nonmatching2', cip19TestVectors.enterpriseScript, assetRepo)
      ] as HandleEntity[]);

      await handleMetadataRepo.save([
        createHandleMetadata('samepayment', false),
        createHandleMetadata('samestake', true)
      ]);
    });

    it('returns all handles associated with payment credential for enterprise addresses', async () => {
      expect(new Set(await queryHandlesByAddressCredentials(queryRunner, cip19TestVectors.enterpriseKey))).toEqual(
        new Set([
          {
            firstMintSlot: block.slot,
            handle: 'sameaddress',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: false
          },
          {
            firstMintSlot: block.slot,
            handle: 'samepayment',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: false
          },
          {
            firstMintSlot: block.slot,
            handle: 'samepayment2',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: false
          },
          {
            firstMintSlot: block.slot,
            handle: 'samepaymententerprise',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: false
          }
        ])
      );
    });

    it('returns all handles associated with either credential for base addresses', async () => {
      expect(
        new Set(await queryHandlesByAddressCredentials(queryRunner, cip19TestVectors.basePaymentKeyStakeKey))
      ).toEqual(
        new Set([
          {
            firstMintSlot: block.slot,
            handle: 'sameaddress',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: true
          },
          {
            firstMintSlot: block.slot,
            handle: 'samepayment',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: false
          },
          {
            firstMintSlot: block.slot,
            handle: 'samepayment2',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: false
          },
          {
            firstMintSlot: block.slot,
            handle: 'samepaymententerprise',
            og: false,
            parent_handle_handle: null,
            samePaymentCredential: true,
            sameStakeCredential: false
          },
          {
            firstMintSlot: block.slot,
            handle: 'samestake',
            og: true,
            parent_handle_handle: null,
            samePaymentCredential: false,
            sameStakeCredential: true
          }
        ] as DefaultHandleParamsQueryResponse[])
      );
    });
  });

  it('sets 1st handle for a base address as default for both credentials', async () => {
    const { firstHandleStored } = await mintFirstHandle();
    expect(firstHandleStored.defaultForPaymentCredential).toBe(firstHandleStored.handle);
    expect(firstHandleStored.defaultForStakeCredential).toBe(firstHandleStored.handle);
  });

  it('sets 1st handle for an enterprise address as default for payment credential', async () => {
    const { storedHandle } = await mintHandle(cip19TestVectors.enterpriseKey, false, 5, Cardano.BlockNo(0));
    expect(storedHandle.defaultForPaymentCredential).toBe(storedHandle.handle);
    expect(storedHandle.defaultForStakeCredential).toBeNull();
  });

  it('updates default handle when a handle that takes precedence is minted', async () => {
    const { firstHandle, firstHandleEvent } = await mintFirstHandle();
    const { storedHandle } = await mintHandle(
      firstHandle.latestOwnerAddress!,
      true,
      firstHandle.handle.length + 1,
      firstHandleEvent.block.header.blockNo
    );
    const updatedFirstHandle = await handleRepository.findOneOrFail({ where: { handle: firstHandle.handle } });
    expect(updatedFirstHandle.defaultForPaymentCredential).toBe(storedHandle.handle);
    expect(updatedFirstHandle.defaultForStakeCredential).toBe(storedHandle.handle);
    expect(storedHandle.defaultForPaymentCredential).toBe(storedHandle.handle);
    expect(storedHandle.defaultForStakeCredential).toBe(storedHandle.handle);
  });

  it('sets default to an existing handle when minted handle does not take precendence', async () => {
    const { firstHandle, firstHandleEvent } = await mintFirstHandle();
    const { storedHandle } = await mintHandle(
      firstHandle.latestOwnerAddress!,
      false,
      firstHandle.handle.length + 1,
      firstHandleEvent.block.header.blockNo
    );
    expect(storedHandle.defaultForPaymentCredential).toBe(firstHandle.handle);
    expect(storedHandle.defaultForStakeCredential).toBe(firstHandle.handle);
  });
});
