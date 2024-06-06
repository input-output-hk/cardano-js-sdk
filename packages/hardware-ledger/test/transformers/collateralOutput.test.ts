import * as Ledger from '@cardano-foundation/ledgerjs-hw-app-cardano';
import { CONTEXT_WITH_KNOWN_ADDRESSES, txOutWithReferenceScriptWithInlineDatum } from '../testData.js';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import { mapCollateralTxOut } from '../../src/transformers/collateralOutput.js';
import type { Cardano } from '@cardano-sdk/core';

describe('collateralOutput', () => {
  describe('mapCollateralTxOut', () => {
    it('returns null if the collateral output is undefined', async () => {
      const coreCollateral: Cardano.TxOut | undefined = undefined;
      const collateral = mapCollateralTxOut(coreCollateral, CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(collateral).toEqual(null);
    });

    it('can map a collateral output', async () => {
      const collateral = mapCollateralTxOut(txOutWithReferenceScriptWithInlineDatum, CONTEXT_WITH_KNOWN_ADDRESSES);

      expect(collateral).toEqual({
        amount: 10n,
        datum: {
          datumHex: '187b',
          type: Ledger.DatumType.INLINE
        },
        destination: {
          params: {
            params: {
              spendingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                1,
                0
              ],
              stakingPath: [
                util.harden(CardanoKeyConst.PURPOSE),
                util.harden(CardanoKeyConst.COIN_TYPE),
                util.harden(0),
                2,
                0
              ]
            },
            type: Ledger.AddressType.BASE_PAYMENT_KEY_STAKE_KEY
          },
          type: Ledger.TxOutputDestinationType.DEVICE_OWNED
        },
        format: Ledger.TxOutputFormat.MAP_BABBAGE,
        referenceScriptHex: '82015820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450',
        tokenBundle: null
      });
    });
  });
});
