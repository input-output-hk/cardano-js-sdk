import * as Cardano from '../../../src/Cardano';
import { AccountBalanceInterval, TransactionBody } from '../../../src/Serialization';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { vectorsForRule } from '../dijkstraVectors';

const KEY_HASH_A = '00112233445566778899aabbccddeeff00112233445566778899aabb';
const KEY_HASH_B = 'ffeeddccbbaa99887766554433221100ffeeddccbbaa998877665544';
const SCRIPT_HASH = 'aabbccddeeff00112233445566778899aabbccddeeff001122334455';

const credABytes = `8200581c${KEY_HASH_A}`;
const credBBytes = `8200581c${KEY_HASH_B}`;
const credSBytes = `8201581c${SCRIPT_HASH}`;

const bothBoundsHex = '821864191388';
const lowerOnlyHex = '821901f4f6';
const upperOnlyHex = '82f6192710';

const bodyPrefix = 'a400d90102818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000180020a';
const noIntervalsBodyCbor = HexBlob(
  'a300d90102818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000180020a'
);

const canonicalBodyCbor = HexBlob(
  `${bodyPrefix}181aa3${credABytes}${bothBoundsHex}${credBBytes}${lowerOnlyHex}${credSBytes}${upperOnlyHex}`
);
const reversedBodyCbor = HexBlob(`${bodyPrefix}181aa2${credBBytes}${lowerOnlyHex}${credABytes}${bothBoundsHex}`);
const emptyIntervalsBodyCbor = HexBlob(`${bodyPrefix}181aa0`);

const bothNilMessage = 'Both interval bounds cannot be nil.';
const [lowerOnlyVector, upperOnlyVector, bothBoundsVector] = vectorsForRule('account_balance_interval');
const [intervalsVector] = vectorsForRule('account_balance_intervals');
const sharedVectorBodyCbor = HexBlob(`${bodyPrefix}181a${intervalsVector.hex}`);

const credA: Cardano.Credential = { hash: Hash28ByteBase16(KEY_HASH_A), type: Cardano.CredentialType.KeyHash };
const credB: Cardano.Credential = { hash: Hash28ByteBase16(KEY_HASH_B), type: Cardano.CredentialType.KeyHash };
const credS: Cardano.Credential = { hash: Hash28ByteBase16(SCRIPT_HASH), type: Cardano.CredentialType.ScriptHash };

const txIn: Cardano.TxIn = {
  index: 0,
  txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
};

const baseCore: Cardano.TxBody = {
  fee: 10n,
  inputs: [txIn],
  outputs: []
};

const intervalsCore: Cardano.TxBody = {
  ...baseCore,
  accountBalanceIntervals: [
    { credential: credA, interval: { exclusiveUpperBound: 5000n, inclusiveLowerBound: 100n } },
    { credential: credB, interval: { inclusiveLowerBound: 500n } },
    { credential: credS, interval: { exclusiveUpperBound: 10_000n } }
  ]
};

describe('AccountBalanceInterval', () => {
  describe('round trip', () => {
    it('round trips the both-bounds shape byte-exact', () => {
      const interval = AccountBalanceInterval.fromCbor(HexBlob(bothBoundsVector.hex));

      expect(interval.inclusiveLowerBound()).toEqual(100n);
      expect(interval.exclusiveUpperBound()).toEqual(5000n);
      expect(interval.toCbor()).toEqual(bothBoundsVector.hex);
      expect(AccountBalanceInterval.fromCore(interval.toCore()).toCbor()).toEqual(bothBoundsVector.hex);
    });

    it('round trips the lower-bound-only shape byte-exact', () => {
      const interval = AccountBalanceInterval.fromCbor(HexBlob(lowerOnlyVector.hex));

      expect(interval.inclusiveLowerBound()).toEqual(500n);
      expect(interval.exclusiveUpperBound()).toBeUndefined();
      expect(interval.toCbor()).toEqual(lowerOnlyVector.hex);
      expect(AccountBalanceInterval.fromCore(interval.toCore()).toCbor()).toEqual(lowerOnlyVector.hex);
    });

    it('round trips the upper-bound-only shape byte-exact', () => {
      const interval = AccountBalanceInterval.fromCbor(HexBlob(upperOnlyVector.hex));

      expect(interval.inclusiveLowerBound()).toBeUndefined();
      expect(interval.exclusiveUpperBound()).toEqual(10_000n);
      expect(interval.toCbor()).toEqual(upperOnlyVector.hex);
      expect(AccountBalanceInterval.fromCore(interval.toCore()).toCbor()).toEqual(upperOnlyVector.hex);
    });
  });

  describe('both-nil rejection', () => {
    it('rejects [null, null] on decode', () => {
      expect(() => AccountBalanceInterval.fromCbor(HexBlob('82f6f6'))).toThrowError(bothNilMessage);
    });

    it('rejects encoding an interval with no bounds', () => {
      expect(() => new AccountBalanceInterval().toCbor()).toThrowError(bothNilMessage);
    });
  });

  describe('bound of zero', () => {
    it('decodes a zero lower bound as 0 rather than nil', () => {
      const interval = AccountBalanceInterval.fromCbor(HexBlob('8200f6'));

      expect(interval.inclusiveLowerBound()).toEqual(0n);
      expect(interval.exclusiveUpperBound()).toBeUndefined();
      expect(interval.toCbor()).toEqual('8200f6');
    });

    it('encodes a zero bound distinctly from an absent bound', () => {
      expect(new AccountBalanceInterval(0n, 10_000n).toCbor()).toEqual('8200192710');
      expect(new AccountBalanceInterval(undefined, 10_000n).toCbor()).toEqual('82f6192710');
    });
  });

  describe('setters', () => {
    it('invalidates cached original bytes on update', () => {
      const interval = AccountBalanceInterval.fromCbor(HexBlob(upperOnlyVector.hex));
      interval.setInclusiveLowerBound(100n);

      expect(interval.toCbor()).toEqual('821864192710');
    });

    it('rejects a both-nil interval in fromCore', () => {
      expect(() => AccountBalanceInterval.fromCore({})).toThrowError(bothNilMessage);
    });

    it('rejects encoding after clearing the only bound', () => {
      const interval = AccountBalanceInterval.fromCbor(HexBlob(lowerOnlyVector.hex));
      interval.setInclusiveLowerBound();

      expect(() => interval.toCbor()).toThrowError(bothNilMessage);
    });
  });
});

describe('TransactionBody account balance intervals (key 26)', () => {
  describe('round trip', () => {
    it('round trips a body with all three interval shapes byte-exact', () => {
      const body = TransactionBody.fromCbor(canonicalBodyCbor);
      const intervals = body.accountBalanceIntervals();

      expect(intervals?.size).toEqual(3);
      expect([...intervals!].map(([credential, interval]) => [credential.toCore(), interval.toCore()])).toEqual([
        [credA, { exclusiveUpperBound: 5000n, inclusiveLowerBound: 100n }],
        [credB, { inclusiveLowerBound: 500n }],
        [credS, { exclusiveUpperBound: 10_000n }]
      ]);
      expect(body.toCbor()).toEqual(canonicalBodyCbor);
      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(canonicalBodyCbor);
    });

    it('preserves a non-canonical decoded map order on re-encode via original bytes', () => {
      const body = TransactionBody.fromCbor(reversedBodyCbor);

      expect([...body.accountBalanceIntervals()!.keys()].map((credential) => credential.toCore())).toEqual([
        credB,
        credA
      ]);
      expect(body.toCbor()).toEqual(reversedBodyCbor);
    });

    it('sorts account balance intervals canonically when rebuilt from core', () => {
      const body = TransactionBody.fromCbor(reversedBodyCbor);

      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(
        `${bodyPrefix}181aa2${credABytes}${bothBoundsHex}${credBBytes}${lowerOnlyHex}`
      );
    });

    it('round trips a body embedding the shared single-entry dijkstra vector', () => {
      const body = TransactionBody.fromCbor(sharedVectorBodyCbor);

      expect(body.toCbor()).toEqual(sharedVectorBodyCbor);
      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(sharedVectorBodyCbor);
    });
  });

  describe('non-empty enforcement', () => {
    it('rejects an empty map at key 26 on decode', () => {
      expect(() => TransactionBody.fromCbor(emptyIntervalsBodyCbor)).toThrowError(
        'account_balance_intervals (transaction body key 26) must be a non-empty map'
      );
    });
  });

  describe('omission when unset', () => {
    it('leaves bodies without key 26 unaffected', () => {
      const body = TransactionBody.fromCbor(noIntervalsBodyCbor);

      expect(body.accountBalanceIntervals()).toBeUndefined();
      expect(body.toCore().accountBalanceIntervals).toBeUndefined();
      expect(body.toCbor()).toEqual(noIntervalsBodyCbor);
    });

    it('omits key 26 when the core field is absent', () => {
      expect(TransactionBody.fromCore(baseCore).toCbor()).toEqual(noIntervalsBodyCbor);
    });

    it('omits key 26 when the map is set but empty', () => {
      const body = TransactionBody.fromCore(baseCore);
      body.setAccountBalanceIntervals(new Map());

      expect(body.toCbor()).toEqual(noIntervalsBodyCbor);
    });
  });

  describe('toCore/fromCore symmetry', () => {
    it('maps key 26 to the accountBalanceIntervals core field', () => {
      expect(TransactionBody.fromCbor(canonicalBodyCbor).toCore().accountBalanceIntervals).toEqual(
        intervalsCore.accountBalanceIntervals
      );
    });

    it('encodes the accountBalanceIntervals core field as key 26', () => {
      expect(TransactionBody.fromCore(intervalsCore).toCbor()).toEqual(canonicalBodyCbor);
    });

    it('is symmetric through fromCore -> toCore', () => {
      expect(TransactionBody.fromCore(intervalsCore).toCore().accountBalanceIntervals).toEqual(
        intervalsCore.accountBalanceIntervals
      );
    });
  });

  describe('setter', () => {
    it('setAccountBalanceIntervals invalidates cached original bytes', () => {
      const body = TransactionBody.fromCbor(reversedBodyCbor);
      body.setAccountBalanceIntervals(body.accountBalanceIntervals()!);

      expect(body.toCbor()).toEqual(`${bodyPrefix}181aa2${credABytes}${bothBoundsHex}${credBBytes}${lowerOnlyHex}`);
    });
  });
});
