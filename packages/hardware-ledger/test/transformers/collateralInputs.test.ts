import { CONTEXT_WITH_KNOWN_ADDRESSES, txIn } from '../testData';
import { CardanoKeyConst, KeyPurpose, TxInId, util } from '@cardano-sdk/key-management';
import { mapCollateralTxIns } from '../../src/transformers';

describe('collateralInputs', () => {
  describe('mapCollateralTxIns', () => {
    it('return null if given an undefined object as collateral txIns', async () => {
      const txIns = mapCollateralTxIns(undefined, CONTEXT_WITH_KNOWN_ADDRESSES);
      expect(txIns).toEqual(null);
    });

    it('can map a a set of collateral inputs', async () => {
      const keyPath = {
        index: 0,
        purpose: KeyPurpose.STANDARD,
        role: 1
      };
      const txIns = mapCollateralTxIns([txIn, txIn, txIn], {
        ...CONTEXT_WITH_KNOWN_ADDRESSES,
        txInKeyPathMap: {
          [TxInId(txIn)]: keyPath
        }
      });

      expect(txIns!.length).toEqual(3);

      for (const input of txIns!) {
        expect(input).toEqual({
          outputIndex: 0,
          path: [
            util.harden(CardanoKeyConst.PURPOSE),
            util.harden(CardanoKeyConst.COIN_TYPE),
            util.harden(CONTEXT_WITH_KNOWN_ADDRESSES.accountIndex),
            keyPath.role,
            keyPath.index
          ],
          txHashHex: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5'
        });
      }

      expect.assertions(4);
    });
  });
});
