import { Cardano } from '@cardano-sdk/core';
import {
  assetIdFromHandle,
  handleAssetName,
  handleOutputs,
  handlePolicyId,
  invalidHandle,
  maryHandleOne,
  referenceNftOutput,
  userNftOutput
} from './handleUtil.js';
import { firstValueFrom, of } from 'rxjs';
import { logger, mockProviders } from '@cardano-sdk/util-dev';
import {
  withCIP67,
  withHandleMetadata,
  withMint,
  withNftMetadata,
  withUtxo
} from '../../../src/operators/Mappers/index.js';
import type { Handle } from '@cardano-sdk/core';
import type { ProjectionEvent } from '../../../src/index.js';

const project = (tx: Cardano.OnChainTx) =>
  firstValueFrom(
    of({
      block: {
        body: [tx],
        header: mockProviders.ledgerTip
      }
    } as ProjectionEvent).pipe(
      withUtxo(),
      withMint(),
      withCIP67(),
      withNftMetadata({ logger }),
      withHandleMetadata({ policyIds: [handlePolicyId] }, logger)
    )
  );

const createCip25HandleMetadata = (handle: Handle) => ({
  blob: new Map([
    [
      721n,
      new Map<Cardano.Metadatum, Cardano.Metadatum>([
        [
          handlePolicyId,
          new Map([
            [
              handleAssetName(handle),
              new Map<Cardano.Metadatum, Cardano.Metadatum>([
                ['name', `$${handle}`],
                ['description', 'The Handle Standard'],
                ['website', 'https://adahandle.com'],
                ['image', 'ipfs://QmZqUk6nGqYJZzHiCGzbzqppA5qE99yNkuTSHuRQpymE1X'],
                [
                  'core',
                  new Map<Cardano.Metadatum, Cardano.Metadatum>([
                    ['og', 1n],
                    ['termsofuse', 'https://adahandle.com/tou'],
                    ['handleEncoding', 'utf-8'],
                    ['prefix', '$'],
                    ['version', 0n]
                  ])
                ],
                ['augmentations', []]
              ])
            ]
          ])
        ]
      ])
    ]
  ])
});

describe('withHandleMetadata', () => {
  it('maps "og" when handle is minted with cip25 metadata', async () => {
    const { handleMetadata } = await project({
      auxiliaryData: createCip25HandleMetadata(maryHandleOne),
      body: {
        mint: new Map([[assetIdFromHandle(maryHandleOne), 1n]]),
        outputs: [handleOutputs.oneHandleMary]
      }
    } as Cardano.OnChainTx);

    expect(handleMetadata).toHaveLength(1);
    expect(handleMetadata[0].og).toBe(true);
    expect(handleMetadata[0].txOut).toBeUndefined();
  });

  it('ignores handles with invalid name', async () => {
    const { handleMetadata } = await project({
      auxiliaryData: createCip25HandleMetadata(invalidHandle),
      body: {
        mint: new Map([[assetIdFromHandle(invalidHandle), 1n]]),
        outputs: [handleOutputs.oneHandleMary]
      }
    } as Cardano.OnChainTx);

    expect(handleMetadata).toHaveLength(0);
  });

  describe('cip68', () => {
    it('maps metadata fields when only reference token is present', async () => {
      const { handleMetadata } = await project({
        body: { outputs: [referenceNftOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handleMetadata).toHaveLength(1);
      expect(typeof handleMetadata[0].og).toBe('boolean');
      expect(typeof handleMetadata[0].txOut).toBe('object');
      expect(typeof handleMetadata[0].backgroundImage).toBe('string');
      expect(typeof handleMetadata[0].profilePicImage).toBe('string');
    });

    it('does not change metadata when only user token is not present', async () => {
      const { handleMetadata } = await project({
        body: { outputs: [userNftOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handleMetadata).toHaveLength(0);
    });

    it('maps metadata fields when both reference and user tokens are present', async () => {
      const { handleMetadata } = await project({
        body: { outputs: [userNftOutput, referenceNftOutput] },
        inputSource: Cardano.InputSource.inputs
      } as Cardano.OnChainTx);

      expect(handleMetadata).toHaveLength(1);
      expect(typeof handleMetadata[0].og).toBe('boolean');
      expect(typeof handleMetadata[0].txOut).toBe('object');
      expect(typeof handleMetadata[0].backgroundImage).toBe('string');
      expect(typeof handleMetadata[0].profilePicImage).toBe('string');
    });
  });
});
