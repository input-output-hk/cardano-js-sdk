import * as Cardano from '../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { TransactionBody } from '../../../src/Serialization';
import { vectorsForRule } from '../dijkstraVectors';

const accountA = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
const accountB = Cardano.RewardAccount('stake_test1upqykkjq3zhf4085s6n70w8cyp57dl87r0ezduv9rnnj2uqk5zmdv');

const accountABytes = '581de013cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d0';
const accountBBytes = '581de0404b5a4088ae9abcf486a7e7b8f82069e6fcfe1bf226f1851ce72570';

const bodyPrefix = 'a400818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000180020a';
const noDepositsBodyCbor = HexBlob(
  'a300818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000180020a'
);

const canonicalBodyCbor = HexBlob(`${bodyPrefix}1819a2${accountABytes}1903e8${accountBBytes}1907d0`);
const reversedBodyCbor = HexBlob(`${bodyPrefix}1819a2${accountBBytes}1907d0${accountABytes}1903e8`);
const emptyDepositsBodyCbor = HexBlob(`${bodyPrefix}1819a0`);

const [singleAccountVector] = vectorsForRule('direct_deposits');
const singleAccountBodyCbor = HexBlob(`${bodyPrefix}1819${singleAccountVector.hex}`);
const mainnetAccount = Cardano.Address.fromBytes(
  HexBlob('e100112233445566778899aabbccddeeff00112233445566778899aabb')
).toBech32() as Cardano.RewardAccount;

const txIn: Cardano.TxIn = {
  index: 0,
  txId: Cardano.TransactionId('0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5')
};

const baseCore: Cardano.TxBody = {
  fee: 10n,
  inputs: [txIn],
  outputs: []
};

const depositsCore: Cardano.TxBody = {
  ...baseCore,
  directDeposits: [
    { quantity: 1000n, stakeAddress: accountA },
    { quantity: 2000n, stakeAddress: accountB }
  ]
};

describe('TransactionBody direct deposits (key 25)', () => {
  describe('round trip', () => {
    it('round trips a body with two direct deposit accounts byte-exact', () => {
      const body = TransactionBody.fromCbor(canonicalBodyCbor);

      expect(body.toCbor()).toEqual(canonicalBodyCbor);
      expect(body.directDeposits()).toEqual(
        new Map([
          [accountA, 1000n],
          [accountB, 2000n]
        ])
      );
      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(canonicalBodyCbor);
    });

    it('preserves a non-canonical decoded map order on re-encode via original bytes', () => {
      const body = TransactionBody.fromCbor(reversedBodyCbor);

      expect([...body.directDeposits()!.keys()]).toEqual([accountB, accountA]);
      expect(body.toCbor()).toEqual(reversedBodyCbor);
    });

    it('sorts direct deposits canonically when rebuilt from core', () => {
      const body = TransactionBody.fromCbor(reversedBodyCbor);

      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(canonicalBodyCbor);
    });

    it('round trips a body embedding the shared single-account dijkstra vector', () => {
      const body = TransactionBody.fromCbor(singleAccountBodyCbor);

      expect(body.toCbor()).toEqual(singleAccountBodyCbor);
      expect(body.directDeposits()).toEqual(new Map([[mainnetAccount, 1_000_000n]]));
      expect(TransactionBody.fromCore(body.toCore()).toCbor()).toEqual(singleAccountBodyCbor);
    });
  });

  describe('non-empty enforcement', () => {
    it('rejects an empty map at key 25 on decode', () => {
      expect(() => TransactionBody.fromCbor(emptyDepositsBodyCbor)).toThrowError(
        'direct_deposits (transaction body key 25) must be a non-empty map'
      );
    });
  });

  describe('omission when unset', () => {
    it('leaves bodies without key 25 unaffected', () => {
      const body = TransactionBody.fromCbor(noDepositsBodyCbor);

      expect(body.directDeposits()).toBeUndefined();
      expect(body.toCore().directDeposits).toBeUndefined();
      expect(body.toCbor()).toEqual(noDepositsBodyCbor);
    });

    it('omits key 25 when the core field is absent', () => {
      expect(TransactionBody.fromCore(baseCore).toCbor()).toEqual(noDepositsBodyCbor);
    });

    it('omits key 25 when the map is set but empty', () => {
      const body = TransactionBody.fromCore(baseCore);
      body.setDirectDeposits(new Map());

      expect(body.toCbor()).toEqual(noDepositsBodyCbor);
    });
  });

  describe('toCore/fromCore symmetry', () => {
    it('maps key 25 to the directDeposits core field', () => {
      expect(TransactionBody.fromCbor(canonicalBodyCbor).toCore().directDeposits).toEqual(depositsCore.directDeposits);
    });

    it('encodes the directDeposits core field as key 25', () => {
      expect(TransactionBody.fromCore(depositsCore).toCbor()).toEqual(canonicalBodyCbor);
    });

    it('is symmetric through fromCore -> toCore', () => {
      expect(TransactionBody.fromCore(depositsCore).toCore().directDeposits).toEqual(depositsCore.directDeposits);
    });
  });

  describe('setter', () => {
    it('setDirectDeposits invalidates cached original bytes', () => {
      const body = TransactionBody.fromCbor(reversedBodyCbor);
      body.setDirectDeposits(body.directDeposits()!);

      expect(body.toCbor()).toEqual(canonicalBodyCbor);
    });
  });
});
