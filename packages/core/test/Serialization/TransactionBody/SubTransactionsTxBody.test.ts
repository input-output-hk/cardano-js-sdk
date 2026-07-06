import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionBody } from '../../../src/Serialization';
import { setInConwayEra } from '../../../src';
import { vectorsForRule } from '../dijkstraVectors';

const inputCbor = '825820ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e2500';
const subWithAuxDataCbor = '83a300d90102800180031864a0a1016474657374';
const subWithoutAuxDataCbor = '83a200d90102800180a0f6';
const subDuplicateIdCbor = '83a200d90102800180a0a1016474657374';

const bodyPrefix = `a400d9010281${inputCbor}01800200`;

const twoSubsTaggedCbor = HexBlob(`${bodyPrefix}17d9010282${subWithAuxDataCbor}${subWithoutAuxDataCbor}`);
const twoSubsBareCbor = HexBlob(`${bodyPrefix}1782${subWithAuxDataCbor}${subWithoutAuxDataCbor}`);
const duplicateIdsCbor = HexBlob(`${bodyPrefix}17d9010282${subWithoutAuxDataCbor}${subDuplicateIdCbor}`);
const emptyTaggedCbor = HexBlob(`${bodyPrefix}17d9010280`);
const emptyBareCbor = HexBlob(`${bodyPrefix}1780`);
const key24Cbor = HexBlob(`${bodyPrefix}1818a18200581c00112233445566778899aabbccddeeff00112233445566778899aabbf6`);

const ledgerVector = vectorsForRule('transaction_body').find((vector) => vector.name === 'with-sub-transactions')!;
const minimalVector = vectorsForRule('transaction_body').find((vector) => vector.name === 'minimal')!;

const expectedCore: Cardano.TxBody = {
  fee: 0n,
  inputs: [
    {
      index: 0,
      txId: Cardano.TransactionId('ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25')
    }
  ],
  outputs: [],
  subTransactions: [
    {
      auxiliaryData: { blob: new Map<bigint, Cardano.Metadatum>([[1n, 'test']]) },
      body: { inputs: [], outputs: [], validityInterval: { invalidHereafter: Cardano.Slot(100) } },
      witness: { signatures: new Map() }
    },
    {
      body: { inputs: [], outputs: [] },
      witness: { signatures: new Map() }
    }
  ]
};

describe('TransactionBody sub transactions (body key 23)', () => {
  beforeAll(() => setInConwayEra(true));
  afterAll(() => setInConwayEra(false));

  describe('round trips', () => {
    it('round trips the ledger golden body with a singleton sub transaction set byte-exactly', () => {
      const body = TransactionBody.fromCbor(HexBlob(ledgerVector.hex));

      expect(body.toCbor()).toEqual(HexBlob(ledgerVector.hex));
      expect(body.subTransactions()!.size()).toEqual(1);
    });

    it('round trips two sub transactions byte-exactly preserving order', () => {
      const body = TransactionBody.fromCbor(twoSubsTaggedCbor);
      const subTransactions = body.subTransactions()!.values();

      expect(body.toCbor()).toEqual(twoSubsTaggedCbor);
      expect(subTransactions).toHaveLength(2);
      expect(subTransactions[0].auxiliaryData()).not.toBeUndefined();
      expect(subTransactions[1].auxiliaryData()).toBeUndefined();
      expect(subTransactions[0].getId()).not.toEqual(subTransactions[1].getId());
    });

    it('accepts a bare (untagged) array and re-encodes it byte-exactly', () => {
      const body = TransactionBody.fromCbor(twoSubsBareCbor);

      expect(body.toCbor()).toEqual(twoSubsBareCbor);
      expect(body.subTransactions()!.size()).toEqual(2);
    });

    it('emits the 258 tag when the set is rebuilt after decoding a bare array', () => {
      const body = TransactionBody.fromCbor(twoSubsBareCbor);
      const subTransactions = body.subTransactions()!;

      subTransactions.setValues([...subTransactions.values()]);
      body.setSubTransactions(subTransactions);

      expect(body.toCbor()).toEqual(twoSubsTaggedCbor);
    });
  });

  describe('decode rejections', () => {
    it('rejects an empty tagged set', () => {
      expect(() => TransactionBody.fromCbor(emptyTaggedCbor)).toThrowError(
        'sub_transactions (transaction body key 23) must be a non-empty set'
      );
    });

    it('rejects an empty bare array', () => {
      expect(() => TransactionBody.fromCbor(emptyBareCbor)).toThrowError(
        'sub_transactions (transaction body key 23) must be a non-empty set'
      );
    });

    it('rejects duplicate sub transaction ids', () => {
      expect(() => TransactionBody.fromCbor(duplicateIdsCbor)).toThrowError(
        'sub_transactions (transaction body key 23) must not contain duplicate sub transaction ids'
      );
    });

    it('does not admit key 24 at the top level in strict mode', () => {
      expect(() => TransactionBody.fromCbor(key24Cbor, { strict: true })).toThrowError(
        'Unknown transaction body map key: 24'
      );
    });

    it('skips key 24 at the top level without mapping it to anything in permissive mode', () => {
      const body = TransactionBody.fromCbor(key24Cbor);
      const core = body.toCore();

      expect(body.subTransactions()).toBeUndefined();
      expect(core.subTransactions).toBeUndefined();
      expect('requiredTopLevelGuards' in core).toBeFalsy();
    });
  });

  describe('toCore/fromCore', () => {
    it('is symmetric across the whole nesting and preserves order', () => {
      const core = TransactionBody.fromCbor(twoSubsTaggedCbor).toCore();

      expect(core).toEqual(expectedCore);
      expect(core.subTransactions![0].auxiliaryData).not.toBeUndefined();
      expect(core.subTransactions![1].auxiliaryData).toBeUndefined();
      expect(TransactionBody.fromCore(core).toCore()).toEqual(core);
    });

    it('re-encodes the core nesting byte-identically to the tagged vector', () => {
      const body = TransactionBody.fromCore(expectedCore);

      expect(body.toCbor()).toEqual(twoSubsTaggedCbor);
    });
  });

  describe('regression', () => {
    it('leaves the ledger minimal body without key 23 unchanged', () => {
      const body = TransactionBody.fromCbor(HexBlob(minimalVector.hex));

      expect(body.toCbor()).toEqual(HexBlob(minimalVector.hex));
      expect(body.subTransactions()).toBeUndefined();
      expect(body.toCore().subTransactions).toBeUndefined();
    });
  });
});
