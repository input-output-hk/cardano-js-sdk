import { Cardano } from '@cardano-sdk/core';
import { TypeOrmNftMetadataService, createDnsResolver, getConnectionConfig, getEntities } from '../../src';
import { logger, mockProviders } from '@cardano-sdk/util-dev';

describe('TypeOrmNftMetadataService', () => {
  let service: TypeOrmNftMetadataService;

  beforeAll(async () => {
    const dnsResolver = createDnsResolver({ factor: 1.1, maxRetryTime: 1000 }, logger);
    const entities = getEntities(['asset']);
    const connectionConfig$ = getConnectionConfig(dnsResolver, 'test', 'Handle', {
      postgresConnectionStringHandle: process.env.POSTGRES_CONNECTION_STRING_HANDLE!
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

  it('should retrieve metadata for an existing nft', async () => {
    const handleAssetId = Cardano.AssetId(
      '62173b90b567ad4bcf254ad0f76eb374d749d0b25fd82786af6a839a48656c6c6f48616e646c65'
    );
    const nfMetadata = await service.getNftMetadata({
      name: Cardano.AssetId.getAssetName(handleAssetId),
      policyId: Cardano.AssetId.getPolicyId(handleAssetId)
    });

    const response = {
      description: 'The Handle Standard',
      files: null,
      image: 'ipfs://some-hash',
      mediaType: null,
      name: 'HelloHandle'
    };

    expect(nfMetadata).toMatchObject(response);
  });
});
