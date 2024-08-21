/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionOutput } from '../../../src/Serialization';

// Test data used in the following tests was generated with the cardano-serialization-lib
const legacyOutputCbor = HexBlob(
  '83583900537ba48a023f0a3c65e54977ffc2d78c143fb418ef6db058e006d78a7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a58200000000000000000000000000000000000000000000000000000000000000000'
);

const legacyOutputNoDatumCbor = HexBlob(
  '82583900537ba48a023f0a3c65e54977ffc2d78c143fb418ef6db058e006d78a7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a'
);

const babbageAllFieldsCbor = HexBlob(
  'a400583900537ba48a023f0a3c65e54977ffc2d78c143fb418ef6db058e006d78a7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa801821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a028201d81849d8799f0102030405ff03d8185182014e4d01000033222220051200120011'
);

const babbageInlineDatumCbor = HexBlob(
  'a300583900537ba48a023f0a3c65e54977ffc2d78c143fb418ef6db058e006d78a7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa801821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a028201d81849d8799f0102030405ff'
);

const babbageDatumHashCbor = HexBlob(
  '83583900537ba48a023f0a3c65e54977ffc2d78c143fb418ef6db058e006d78a7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a58200000000000000000000000000000000000000000000000000000000000000000'
);

const babbageRefScriptCbor = HexBlob(
  'a300583900537ba48a023f0a3c65e54977ffc2d78c143fb418ef6db058e006d78a7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa801821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a03d8185182014e4d01000033222220051200120011'
);

const babbageNoOptionalFieldScriptCbor = HexBlob(
  '82583900537ba48a023f0a3c65e54977ffc2d78c143fb418ef6db058e006d78a7c16240714ea0e12b41a914f2945784ac494bb19573f0ca61a08afa8821a000f4240a2581c00000000000000000000000000000000000000000000000000000000a3443031323218644433343536186344404142420a581c11111111111111111111111111111111111111111111111111111111a3443031323218644433343536186344404142420a'
);

const maryOutputPointerCbor = HexBlob(
  '825826412813b99a80cfb4024374bd0f502959485aa56e0648564ff805f2e51bbcd9819561bddc66141a02faf080'
);

const canonicallySortedAssets = new Map([
  ['0000000000000000000000000000000000000000000000000000000030313232' as unknown as Cardano.AssetId, 100n],
  ['0000000000000000000000000000000000000000000000000000000033343536' as unknown as Cardano.AssetId, 99n],
  ['0000000000000000000000000000000000000000000000000000000040414242' as unknown as Cardano.AssetId, 10n],
  ['1111111111111111111111111111111111111111111111111111111130313232' as unknown as Cardano.AssetId, 100n],
  ['1111111111111111111111111111111111111111111111111111111133343536' as unknown as Cardano.AssetId, 99n],
  ['1111111111111111111111111111111111111111111111111111111140414242' as unknown as Cardano.AssetId, 10n]
]);

const basicOutput = {
  address: Cardano.PaymentAddress(
    'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
  ),
  datum: undefined,
  datumHash: undefined,
  scriptReference: undefined,
  value: {
    assets: canonicallySortedAssets,
    coins: 1_000_000n
  }
} as Cardano.TxOut;

const outputWithInlineDataCore = {
  ...basicOutput,
  datum: {
    cbor: HexBlob('d8799f0102030405ff'),
    constructor: 0n,
    fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
  }
} as Cardano.TxOut;

const outputWithHashDataCore = {
  ...basicOutput,
  datumHash: HexBlob('0000000000000000000000000000000000000000000000000000000000000000') as unknown as Cardano.DatumHash
} as Cardano.TxOut;

const outputWithRefScriptCore = {
  ...basicOutput,
  scriptReference: {
    __type: 'plutus',
    bytes: HexBlob('4d01000033222220051200120011'),
    version: 0
  }
} as Cardano.TxOut;

const outputWithBothRefScriptAndDatumCore = {
  ...basicOutput,
  datum: {
    cbor: HexBlob('d8799f0102030405ff'),
    constructor: 0n,
    fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
  },
  scriptReference: {
    __type: 'plutus',
    bytes: HexBlob('4d01000033222220051200120011'),
    version: 0
  }
} as Cardano.TxOut;

describe('TransactionOutput', () => {
  describe('Legacy', () => {
    describe('With datum', () => {
      it('can decode TransactionOutput from CBOR', () => {
        const output = TransactionOutput.fromCbor(legacyOutputCbor);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()?.asDataHash()).toEqual(
          '0000000000000000000000000000000000000000000000000000000000000000'
        );
      });

      it('can decode TransactionOutput from Core', () => {
        const output = TransactionOutput.fromCore(outputWithHashDataCore);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()?.asDataHash()).toEqual(
          '0000000000000000000000000000000000000000000000000000000000000000'
        );
      });

      it('can encode TransactionOutput to CBOR', () => {
        const output = TransactionOutput.fromCore(outputWithHashDataCore);

        expect(output.toCbor()).toEqual(legacyOutputCbor);
      });

      it('can encode TransactionOutput to Core', () => {
        const output = TransactionOutput.fromCbor(legacyOutputCbor);
        expect(output.toCore()).toEqual(outputWithHashDataCore);
      });

      it('can decode PointerAddress Output to Core', () => {
        const output = TransactionOutput.fromCbor(maryOutputPointerCbor);
        const address = output.address();
        const hash = address.asPointer()?.getPaymentCredential().hash;
        expect(hash).toEqual('2813b99a80cfb4024374bd0f502959485aa56e0648564ff805f2e51b');
        const pointer = address.asPointer()?.getStakePointer();
        expect(pointer?.slot).toEqual(16_292_793_057n);
        expect(pointer?.certIndex).toEqual(20);
        expect(pointer?.txIndex).toEqual(1_011_302);
        expect(address.toBech32()).toEqual('addr1gy5p8wv6sr8mgqjrwj7s75pft9y94ftwqey9vnlcqhew2xaumxqe2cdam3npgv60hqa');
      });
    });

    describe('With no datum', () => {
      it('can decode TransactionOutput from CBOR', () => {
        const output = TransactionOutput.fromCbor(legacyOutputNoDatumCbor);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()).toBeUndefined();
      });

      it('can decode TransactionOutput from Core', () => {
        const output = TransactionOutput.fromCore(basicOutput);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()).toBeUndefined();
      });

      it('can encode TransactionOutput to CBOR', () => {
        const output = TransactionOutput.fromCore(basicOutput);

        expect(output.toCbor()).toEqual(legacyOutputNoDatumCbor);
      });

      it('can encode TransactionOutput to Core', () => {
        const output = TransactionOutput.fromCbor(legacyOutputNoDatumCbor);
        expect(output.toCore()).toEqual(basicOutput);
      });
    });
  });
  describe('Babbage', () => {
    describe('All fields', () => {
      it('can decode TransactionOutput from CBOR', () => {
        const output = TransactionOutput.fromCbor(babbageAllFieldsCbor);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()!.toCore()).toEqual({
          __type: 'plutus',
          bytes: '4d01000033222220051200120011',
          version: 0
        });
        expect(output.datum()?.asInlineData()?.toCore()).toEqual({
          cbor: HexBlob('d8799f0102030405ff'),
          constructor: 0n,
          fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
        });
      });

      it('can decode TransactionOutput from Core', () => {
        const output = TransactionOutput.fromCore(outputWithBothRefScriptAndDatumCore);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()!.toCore()).toEqual({
          __type: 'plutus',
          bytes: '4d01000033222220051200120011',
          version: 0
        });
        expect(output.datum()?.asInlineData()?.toCore()).toEqual({
          cbor: HexBlob('d8799f0102030405ff'),
          constructor: 0n,
          fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
        });
      });

      it('can encode TransactionOutput to CBOR', () => {
        const output = TransactionOutput.fromCore(outputWithBothRefScriptAndDatumCore);

        expect(output.toCbor()).toEqual(babbageAllFieldsCbor);
      });

      it('can encode TransactionOutput to Core', () => {
        const output = TransactionOutput.fromCbor(babbageAllFieldsCbor);
        expect(output.toCore()).toEqual(outputWithBothRefScriptAndDatumCore);
      });
    });

    describe('Inline Datum', () => {
      it('can decode TransactionOutput from CBOR', () => {
        const output = TransactionOutput.fromCbor(babbageInlineDatumCbor);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()?.asInlineData()?.toCore()).toEqual({
          cbor: HexBlob('d8799f0102030405ff'),
          constructor: 0n,
          fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
        });
      });

      it('can decode TransactionOutput from Core', () => {
        const output = TransactionOutput.fromCore(outputWithInlineDataCore);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()?.asInlineData()?.toCore()).toEqual({
          cbor: HexBlob('d8799f0102030405ff'),
          constructor: 0n,
          fields: { cbor: HexBlob('9f0102030405ff'), items: [1n, 2n, 3n, 4n, 5n] }
        });
      });

      it('can encode TransactionOutput to CBOR', () => {
        const output = TransactionOutput.fromCore(outputWithInlineDataCore);

        expect(output.toCbor()).toEqual(babbageInlineDatumCbor);
      });

      it('can encode TransactionOutput to Core', () => {
        const output = TransactionOutput.fromCbor(babbageInlineDatumCbor);
        expect(output.toCore()).toEqual(outputWithInlineDataCore);
      });
    });

    describe('Datum Hash', () => {
      it('can decode TransactionOutput from CBOR', () => {
        const output = TransactionOutput.fromCbor(babbageDatumHashCbor);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()?.asDataHash()).toEqual(
          HexBlob('0000000000000000000000000000000000000000000000000000000000000000') as unknown as Cardano.DatumHash
        );
      });

      it('can decode TransactionOutput from Core', () => {
        const output = TransactionOutput.fromCore(outputWithHashDataCore);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()?.asDataHash()).toEqual(
          HexBlob('0000000000000000000000000000000000000000000000000000000000000000') as unknown as Cardano.DatumHash
        );
      });

      it('can encode TransactionOutput to CBOR', () => {
        const output = TransactionOutput.fromCore(outputWithHashDataCore);

        expect(output.toCbor()).toEqual(babbageDatumHashCbor);
      });

      it('can encode TransactionOutput to Core', () => {
        const output = TransactionOutput.fromCbor(babbageDatumHashCbor);
        expect(output.toCore()).toEqual(outputWithHashDataCore);
      });
    });

    describe('Script Reference', () => {
      it('can decode TransactionOutput from CBOR', () => {
        const output = TransactionOutput.fromCbor(babbageRefScriptCbor);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()?.toCore()).toEqual({
          __type: 'plutus',
          bytes: HexBlob('4d01000033222220051200120011'),
          version: 0
        });
        expect(output.datum()).toBeUndefined();
      });

      it('can decode TransactionOutput from Core', () => {
        const output = TransactionOutput.fromCore(outputWithRefScriptCore);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()?.toCore()).toEqual({
          __type: 'plutus',
          bytes: HexBlob('4d01000033222220051200120011'),
          version: 0
        });
        expect(output.datum()).toBeUndefined();
      });

      it('can encode TransactionOutput to CBOR', () => {
        const output = TransactionOutput.fromCore(outputWithRefScriptCore);

        expect(output.toCbor()).toEqual(babbageRefScriptCbor);
      });

      it('can encode TransactionOutput to Core', () => {
        const output = TransactionOutput.fromCbor(babbageRefScriptCbor);
        expect(output.toCore()).toEqual(outputWithRefScriptCore);
      });
    });

    describe('No Optional fields', () => {
      it('can decode TransactionOutput from CBOR', () => {
        const output = TransactionOutput.fromCbor(babbageNoOptionalFieldScriptCbor);

        expect(output.address().toBech32()).toEqual(
          'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
        );
        expect(output.amount().coin()).toEqual(1_000_000n);
        expect(output.amount().multiasset()).toEqual(canonicallySortedAssets);
        expect(output.scriptRef()).toBeUndefined();
        expect(output.datum()).toBeUndefined();
      });

      it('can encode TransactionOutput to CBOR', () => {
        const output = TransactionOutput.fromCore(basicOutput);

        expect(output.toCbor()).toEqual(babbageNoOptionalFieldScriptCbor);
      });

      it('can encode TransactionOutput to Core', () => {
        const output = TransactionOutput.fromCbor(babbageNoOptionalFieldScriptCbor);
        expect(output.toCore()).toEqual(basicOutput);
      });
    });
  });
});
