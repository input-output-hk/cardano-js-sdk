/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../src/Cardano/index.js';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionUnspentOutput } from '../../src/Serialization/index.js';

// Test data used in the following tests was generated with the cardano-serialization-lib
const cbor = HexBlob(
  '82825820bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e00182583900287a7e37219128cfb05322626daa8b19d1ad37c6779d21853f7b94177c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8821af0078c21a2581c1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c9601a14350584c05581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c410a'
);

const core = [
  {
    index: 1,
    txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
  },
  {
    address: Cardano.PaymentAddress(
      'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
    ),
    value: {
      assets: new Map([
        [Cardano.AssetId('1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c'), 5n],
        [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), 10n]
      ]),
      coins: 4_027_026_465n
    }
  }
] as Cardano.Utxo;

describe('TransactionUnspentOutput', () => {
  it('can decode TransactionUnspentOutput from CBOR', () => {
    const utxo = TransactionUnspentOutput.fromCbor(cbor);

    expect(utxo.input().toCore()).toEqual({
      index: 1,
      txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
    });
    expect(utxo.output().toCore()).toEqual({
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        assets: new Map([
          [Cardano.AssetId('1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c'), 5n],
          [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), 10n]
        ]),
        coins: 4_027_026_465n
      }
    });
  });

  it('can decode TransactionUnspentOutput from Core', () => {
    const utxo = TransactionUnspentOutput.fromCore(core);

    expect(utxo.input().toCore()).toEqual({
      index: 1,
      txId: Cardano.TransactionId('bb217abaca60fc0ca68c1555eca6a96d2478547818ae76ce6836133f3cc546e0')
    });
    expect(utxo.output().toCore()).toEqual({
      address: Cardano.PaymentAddress(
        'addr_test1qq585l3hyxgj3nas2v3xymd23vvartfhceme6gv98aaeg9muzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q2g7k3g'
      ),
      value: {
        assets: new Map([
          [Cardano.AssetId('1ec85dcee27f2d90ec1f9a1e4ce74a667dc9be8b184463223f9c960150584c'), 5n],
          [Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'), 10n]
        ]),
        coins: 4_027_026_465n
      }
    });
  });

  it('can encode TransactionUnspentOutput to CBOR', () => {
    const utxo = TransactionUnspentOutput.fromCore(core);

    expect(utxo.toCbor()).toEqual(cbor);
  });

  it('can encode TransactionUnspentOutput to Core', () => {
    const utxo = TransactionUnspentOutput.fromCbor(cbor);

    expect(utxo.toCore()).toEqual(core);
  });
});
