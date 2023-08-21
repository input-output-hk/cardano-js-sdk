import { ManagedFreeableScope } from '@cardano-sdk/util';
import { Transaction } from '../../src/Serialization/Transaction';
import { TxCBOR } from '../../src';

describe('reserialization', () => {
  let scope: ManagedFreeableScope;

  const testReserialization = (testName: string, originalSerialized: string) =>
    test(testName, () => {
      const cmlTx = scope.manage(Transaction.fromCbor(TxCBOR(originalSerialized)));
      const deserialized = cmlTx.toCore();
      const cmlTxReserialized = scope.manage(Transaction.fromCore(scope, deserialized));
      const reserialized = cmlTxReserialized.toCbor();
      expect(reserialized).toEqual(originalSerialized);
    });

  beforeEach(() => {
    scope = new ManagedFreeableScope();
  });

  afterEach(() => {
    scope.dispose();
  });

  testReserialization(
    'simple tx',
    '84a30081825820c2df24d66077bc77f5a566b211662fe1bd85820024b37fb1a3f13eca263f80c1010182825839003492aa317ad5a41ceaf03f0ff7ba16b4760c63614d75d02a3fec7d98b903affb7b9b39ecad90b3023e6154764e65e9e7a1567d8f7ff9a6251a002dc6c0825839005cf6c91279a859a072601779fb33bb07c34e1d641d45df51ff63b967f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd801b0000048c2708f81b021a00029125a10081825820368cf6a11ac7e29917568a366af62a596cb9cde8174bfe7f6e88393ecdb1dcc65840b2eb6ad0b749246dc9d6e8f6fca2793781688dadcf364a37c2e3713ede7bd40dd04c48289a0252be3b5ff413e8536879b8482a916e481b472e83169c51a1e508f5f6'
  );
});
