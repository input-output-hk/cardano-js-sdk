import { Cardano, util } from '@cardano-sdk/core';
import { TypeOrmNftMetadataService, createDnsResolver, getConnectionConfig, getEntities } from '../../src';
import { logger, mockProviders } from '@cardano-sdk/util-dev';

describe('TypeOrmNftMetadataService', () => {
  let service: TypeOrmNftMetadataService;

  beforeAll(async () => {
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
    const entities = getEntities(['asset']);
    const connectionConfig$ = getConnectionConfig(dnsResolver, 'test', 'Asset', {
      postgresConnectionStringAsset: process.env.POSTGRES_CONNECTION_STRING_ASSET!
    });
    service = new TypeOrmNftMetadataService({ connectionConfig$, entities, logger });
    await service.initialize();
    await service.start();
  });

  afterAll(async () => {
    jest.restoreAllMocks();
    await service.shutdown();
  });

  it('should return null for a non-existing asset', async () => {
    const nfMetadata = await service.getNftMetadata({
      name: mockProviders.handleAssetInfo.name,
      policyId: mockProviders.handleAssetInfo.policyId
    });

    expect(nfMetadata).toBe(null);
  });

  describe('existing nft', () => {
    const helloHandleAssetId = Cardano.AssetId.fromParts(
      Cardano.PolicyId('62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a'),
      Cardano.AssetName(util.utf8ToHex('hellohandle'))
    );
    const testHandleAssetId = Cardano.AssetId(
      '62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a7465737468616e646c65'
    );

    const helloHandleOtherProperties = new Map<string, string | Array<string> | Map<string, string | bigint>>([
      ['augmentations', []],
      [
        'core',
        new Map<string, string | bigint>([
          ['handleEncoding', 'utf-8'],
          ['og', 0n],
          ['prefix', '$'],
          ['termsofuse', 'https://cardanofoundation.org/en/terms-and-conditions/'],
          ['version', 0n]
        ])
      ],
      ['website', 'https://cardano.org/']
    ]);

    it('should retrieve name and image (all required properties)', async () => {
      const nftMetadata = await service.getNftMetadata({
        name: Cardano.AssetId.getAssetName(helloHandleAssetId),
        policyId: Cardano.AssetId.getPolicyId(helloHandleAssetId)
      });

      const response = {
        description: 'The Handle Standard',
        image: 'ipfs://some-hash',
        name: 'hellohandle',
        otherProperties: helloHandleOtherProperties
      };

      expect(nftMetadata).toEqual(response);
    });

    it("should retrieve otherProperties when they're present", async () => {
      const nftMetadata = await service.getNftMetadata({
        name: Cardano.AssetId.getAssetName(helloHandleAssetId),
        policyId: Cardano.AssetId.getPolicyId(helloHandleAssetId)
      });

      expect(nftMetadata?.otherProperties).toEqual(helloHandleOtherProperties);
    });

    it("should retrieve description when it's present", async () => {
      const nftMetadata = await service.getNftMetadata({
        name: Cardano.AssetId.getAssetName(helloHandleAssetId),
        policyId: Cardano.AssetId.getPolicyId(helloHandleAssetId)
      });

      expect(nftMetadata?.description).toEqual('The Handle Standard');
    });

    it('should retrieve files when they are present', async () => {
      const nftMetadata = await service.getNftMetadata({
        name: Cardano.AssetId.getAssetName(testHandleAssetId),
        policyId: Cardano.AssetId.getPolicyId(testHandleAssetId)
      });

      expect(nftMetadata?.files).toEqual([
        {
          mediaType: 'video/mp4',
          name: 'some name',
          src: 'ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2N5'
        },
        {
          mediaType: 'audio/mpeg',
          name: 'some name',
          src: 'ipfs://Qmb78QQ4RXxKQrteRn4X3WaMXXfmi2BU2dLjfWxuJoF2Ny'
        }
      ]);
    });

    it("should retrieve mediaType when it's present", async () => {
      const nftMetadata = await service.getNftMetadata({
        name: Cardano.AssetId.getAssetName(testHandleAssetId),
        policyId: Cardano.AssetId.getPolicyId(testHandleAssetId)
      });

      expect(nftMetadata?.mediaType).toEqual('image/jpeg');
    });
  });
});
