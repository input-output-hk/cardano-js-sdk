import {
  AccountBalanceInterval,
  Credential,
  Guards,
  NativeScript,
  ProtocolVersion,
  Redeemers,
  Script,
  SubTransaction,
  Transaction,
  TransactionBody,
  TxCBOR
} from '../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';
import { dijkstraVectors, vectorsForRule } from './dijkstraVectors';

type RoundTrip = (hex: string) => string;

const txRoundTrip: RoundTrip = (hex) => Transaction.fromCbor(TxCBOR(hex)).toCbor();

const RULE_ROUND_TRIPS: Record<string, RoundTrip> = {
  account_balance_interval: (hex) => AccountBalanceInterval.fromCbor(HexBlob(hex)).toCbor(),
  credential: (hex) => Credential.fromCbor(HexBlob(hex)).toCbor(),
  guards: (hex) => Guards.fromCbor(HexBlob(hex)).toCbor(),
  native_script: (hex) => NativeScript.fromCbor(HexBlob(hex)).toCbor(),
  protocol_version: (hex) => ProtocolVersion.fromCbor(HexBlob(hex)).toCbor(),
  redeemers: (hex) => Redeemers.fromCbor(HexBlob(hex)).toCbor(),
  script: (hex) => Script.fromCbor(HexBlob(hex)).toCbor(),
  sub_transaction: (hex) => SubTransaction.fromCbor(HexBlob(hex)).toCbor(),
  transaction: txRoundTrip,
  transaction_body: (hex) => TransactionBody.fromCbor(HexBlob(hex)).toCbor(),
  transaction_mempool: txRoundTrip
};

const UNMAPPED_RULES = new Set([
  'account_balance_intervals',
  'direct_deposits',
  'required_top_level_guards',
  'sub_transactions'
]);

const GOLDEN_TX_ID = 'a00370a1a00993575cb067a1f89b0693ae27fbe1ae158c1f7f7026b5a8faee6b';

const REQUIRED_RULES = [
  'account_balance_interval',
  'credential',
  'guards',
  'protocol_version',
  'sub_transaction',
  'transaction'
];

describe('dijkstraVectors', () => {
  it('is not empty', () => {
    expect(dijkstraVectors.length).toBeGreaterThan(0);
  });

  it('has at least one vector for every required rule', () => {
    for (const rule of REQUIRED_RULES) {
      expect(vectorsForRule(rule).length).toBeGreaterThan(0);
    }
  });

  it('covers both guards forms', () => {
    const names = vectorsForRule('guards').map((vector) => vector.name);
    expect(names).toContain('key-hash-set-tagged');
    expect(names).toContain('credential-oset-tagged');
  });

  describe.each(dijkstraVectors)('$rule/$name', (vector) => {
    it('has non-empty lowercase hex of even length', () => {
      expect(vector.hex.length).toBeGreaterThan(0);
      expect(vector.hex).toMatch(/^(?:[\da-f]{2})+$/);
    });

    it('states its provenance', () => {
      expect(vector.provenance.length).toBeGreaterThan(0);
      expect(vector.provenance).toMatch(/cardano-ledger 9b81d994|constructed/);
    });
  });

  it('has unique rule/name pairs', () => {
    const keys = dijkstraVectors.map((vector) => `${vector.rule}/${vector.name}`);
    expect(new Set(keys).size).toBe(keys.length);
  });

  it('maps every rule to a round trip or lists it as unmapped', () => {
    for (const vector of dijkstraVectors) {
      expect(RULE_ROUND_TRIPS[vector.rule] !== undefined || UNMAPPED_RULES.has(vector.rule)).toBe(true);
    }
  });

  describe.each(dijkstraVectors.filter((v) => RULE_ROUND_TRIPS[v.rule]))('round trips $rule/$name', (vector) => {
    it('decodes and re-encodes byte-exact', () => {
      expect(RULE_ROUND_TRIPS[vector.rule](vector.hex)).toEqual(vector.hex);
    });
  });

  describe('ledger golden transaction', () => {
    const golden = vectorsForRule('transaction').find((vector) => vector.name === 'ledger-golden-full')!;

    it('has a stable transaction id and maps to core', () => {
      const tx = Transaction.fromCbor(TxCBOR(golden.hex));

      expect(tx.getId()).toEqual(GOLDEN_TX_ID);
      expect(() => tx.toCore()).not.toThrow();
    });
  });
});
