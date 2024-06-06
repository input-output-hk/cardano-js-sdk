import * as Crypto from '@cardano-sdk/crypto';
import { Cardano, Serialization, SerializationFailure } from '../../src/index.js';
import { HexBlob } from '@cardano-sdk/util';

// Shelley era
const shelleyCbor = HexBlob(
  '82a11902d5a4187b1904d2636b65796576616c7565646b65793246000102030405a1190237656569676874a119029a6463616b65828202818200581c3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e830300818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'
);

const alonzoCbor = HexBlob(
  'd90103a400a11902d5a4187b1904d2636b65796576616c7565646b65793246000102030405a1190237656569676874a119029a6463616b6501848204038205098202818200581c3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e830300818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f540284474601000022001047460100002200114746010000220012474601000022001303844746010000220010474601000022001147460100002200124746010000220013'
);

const metadatum = new Map<Cardano.Metadatum, Cardano.Metadatum>([
  [123n, 1234n],
  ['key', 'value'],
  ['key2', new Uint8Array([0, 1, 2, 3, 4, 5])],
  [
    new Map<Cardano.Metadatum, Cardano.Metadatum>([[567n, 'eight']]),
    new Map<Cardano.Metadatum, Cardano.Metadatum>([[666n, 'cake']])
  ]
]) as Cardano.Metadatum;

const shelleyScripts: Array<Cardano.Script> = [
  {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireAnyOf,
    scripts: [
      {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e'),
        kind: Cardano.NativeScriptKind.RequireSignature
      }
    ]
  },
  {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireNOf,
    required: 0,
    scripts: [
      {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
        kind: Cardano.NativeScriptKind.RequireSignature
      }
    ]
  }
];

const alonzoScripts: Array<Cardano.Script> = [
  {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('46010000220010'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('46010000220011'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('46010000220012'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('46010000220013'),
    version: Cardano.PlutusLanguageVersion.V1
  },
  {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('46010000220010'),
    version: Cardano.PlutusLanguageVersion.V2
  },
  {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('46010000220011'),
    version: Cardano.PlutusLanguageVersion.V2
  },
  {
    __type: Cardano.ScriptType.Plutus,
    bytes: HexBlob('46010000220012'),
    version: Cardano.PlutusLanguageVersion.V2
  },
  { __type: Cardano.ScriptType.Plutus, bytes: HexBlob('46010000220013'), version: Cardano.PlutusLanguageVersion.V2 },
  { __type: Cardano.ScriptType.Native, kind: 4, slot: Cardano.Slot(3) },
  { __type: Cardano.ScriptType.Native, kind: 5, slot: Cardano.Slot(9) },
  {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireAnyOf,
    scripts: [
      {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('3542acb3a64d80c29302260d62c3b87a742ad14abf855ebc6733081e'),
        kind: Cardano.NativeScriptKind.RequireSignature
      }
    ]
  },
  {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireNOf,
    required: 0,
    scripts: [
      {
        __type: Cardano.ScriptType.Native,
        keyHash: Crypto.Ed25519KeyHashHex('b5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54'),
        kind: Cardano.NativeScriptKind.RequireSignature
      }
    ]
  }
];

const shelleyCore: Cardano.AuxiliaryData = {
  blob: new Map([[725n, metadatum]]),
  scripts: shelleyScripts
};

const alonzoCore: Cardano.AuxiliaryData = {
  blob: new Map([[725n, metadatum]]),
  scripts: alonzoScripts
};

describe('AuxiliaryData', () => {
  describe('Shelley auxiliary data', () => {
    it('can encode TransactionWitnessSet to CBOR', () => {
      const data = Serialization.AuxiliaryData.fromCore(shelleyCore);
      expect(data.toCbor()).toEqual(shelleyCbor);
    });

    it('can encode TransactionWitnessSet to Core', () => {
      const data = Serialization.AuxiliaryData.fromCbor(shelleyCbor);
      expect(data.toCore()).toEqual(shelleyCore);
    });
  });

  describe('Alonzo auxiliary data', () => {
    it('can encode TransactionWitnessSet to CBOR', () => {
      const data = Serialization.AuxiliaryData.fromCore(alonzoCore);
      expect(data.toCbor()).toEqual(alonzoCbor);
    });

    it('can encode TransactionWitnessSet to Core', () => {
      const data = Serialization.AuxiliaryData.fromCbor(alonzoCbor);
      expect(data.toCore()).toEqual(alonzoCore);
    });
  });

  describe('metadatum', () => {
    // eslint-disable-next-line unicorn/consistent-function-scoping, @typescript-eslint/no-explicit-any
    const convertMetadatum = (data: any) => {
      const label = 123n;
      const auxiliaryData = Serialization.AuxiliaryData.fromCore({ blob: new Map([[label, data]]) });
      return auxiliaryData.metadata()!.metadata()!.get(label);
    };

    const str64Len = 'looooooooooooooooooooooooooooooooooooooooooooooooooooooooooogstr';
    const str65Len = 'loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooogstr';

    it('converts number', () => {
      const number = 1234n;
      expect(convertMetadatum(number)!.asInteger()).toBe(number);
    });

    it('converts text', () => {
      expect(convertMetadatum(str64Len)!.asText()).toBe(str64Len);
    });

    it('converts list', () => {
      const list = [str64Len, 'str2'];
      const medataumList = convertMetadatum(list)!.asList();

      expect(medataumList!.getLength()).toBe(list.length);
      expect(medataumList!.get(0)!.asText()).toBe(list[0]);
      expect(medataumList!.get(1)!.asText()).toBe(list[1]);
    });

    test('converts bytes', () => {
      const bytes = Buffer.from(str64Len).valueOf();
      const metadatumBytes = convertMetadatum(bytes);
      expect(metadatumBytes!.asBytes()).toEqual(bytes);
    });

    it('converts map', () => {
      const key = new Map<Cardano.Metadatum, Cardano.Metadatum>([[567n, 'eight']]);
      const map = new Map<Cardano.Metadatum, Cardano.Metadatum>([
        [123n, 1234n],
        ['key', 'value'],
        [key, new Map<Cardano.Metadatum, Cardano.Metadatum>([[666n, 'cake']])]
      ]);
      const metadatumMap = convertMetadatum(map)!.asMap();
      const metadatum1 = metadatumMap!.get(convertMetadatum(123n)!);
      const metadatum2 = metadatumMap!.get(convertMetadatum('key')!);
      const metadatum3 = metadatumMap!.get(convertMetadatum(key)!);
      const metadatum1AsInt = metadatum1!.asInteger();
      const metadatum3AsMap = metadatum3!.asMap();

      expect(metadatumMap!.getLength()).toBe(map.size);
      expect(metadatum1AsInt).toBe(1234n);
      expect(metadatum2!.asText()).toBe('value');
      expect(metadatum3AsMap!.get(Serialization.TransactionMetadatum.newInteger(666n))!.asText()).toBe('cake');
    });

    test('bytes too long throws error', () => {
      const bytes = Buffer.from(str65Len, 'utf8');
      expect(() => convertMetadatum(bytes)).toThrow(SerializationFailure.MaxLengthLimit);
    });

    it('text too long throws error', () => {
      expect(() => convertMetadatum(str65Len)).toThrow(SerializationFailure.MaxLengthLimit);
    });

    it('bool throws error', () => {
      expect(() => convertMetadatum(true)).toThrowError(SerializationFailure.InvalidType);
    });

    it('undefined throws error', () => {
      // eslint-disable-next-line unicorn/no-useless-undefined
      expect(() => convertMetadatum(undefined)).toThrowError(SerializationFailure.InvalidType);
    });

    it('null throws error', () => {
      expect(() => convertMetadatum(null)).toThrowError(SerializationFailure.InvalidType);
    });

    it('can find an element in a metadatum map with key - Integer', () => {
      const data = new Serialization.MetadatumMap();

      data.insert(Serialization.TransactionMetadatum.newInteger(1n), Serialization.TransactionMetadatum.newInteger(2n));

      expect(data.get(Serialization.TransactionMetadatum.newInteger(1n))).toEqual(
        Serialization.TransactionMetadatum.newInteger(2n)
      );
      expect(data.get(Serialization.TransactionMetadatum.newInteger(2n))).toBeUndefined();
    });

    it('can find an element in a metadatum map with key - Text', () => {
      const data = new Serialization.MetadatumMap();

      data.insert(
        Serialization.TransactionMetadatum.newText('someKey'),
        Serialization.TransactionMetadatum.newInteger(2n)
      );

      expect(data.get(Serialization.TransactionMetadatum.newText('someKey'))).toEqual(
        Serialization.TransactionMetadatum.newInteger(2n)
      );
      expect(data.get(Serialization.TransactionMetadatum.newText('someOtherKey'))).toBeUndefined();
    });

    it('can find an element in a metadatum map with key - Bytes', () => {
      const data = new Serialization.MetadatumMap();

      data.insert(
        Serialization.TransactionMetadatum.newBytes(new Uint8Array([0, 1, 2])),
        Serialization.TransactionMetadatum.newInteger(2n)
      );

      expect(data.get(Serialization.TransactionMetadatum.newBytes(new Uint8Array([0, 1, 2])))).toEqual(
        Serialization.TransactionMetadatum.newInteger(2n)
      );

      expect(data.get(Serialization.TransactionMetadatum.newBytes(new Uint8Array([0, 1, 2, 3])))).toBeUndefined();
    });

    it('can find an element in a metadatum map with key - MetadatumList', () => {
      const data = new Serialization.MetadatumMap();

      const list1 = new Serialization.MetadatumList();
      list1.add(Serialization.TransactionMetadatum.newInteger(1n));
      list1.add(Serialization.TransactionMetadatum.newInteger(2n));
      list1.add(Serialization.TransactionMetadatum.newInteger(5n));

      const list2 = new Serialization.MetadatumList();
      list2.add(Serialization.TransactionMetadatum.newInteger(1n));
      list2.add(Serialization.TransactionMetadatum.newInteger(2n));
      list2.add(Serialization.TransactionMetadatum.newInteger(5n));

      const list3 = new Serialization.MetadatumList();
      list3.add(Serialization.TransactionMetadatum.newInteger(1n));
      list3.add(Serialization.TransactionMetadatum.newInteger(2n));

      data.insert(Serialization.TransactionMetadatum.newList(list1), Serialization.TransactionMetadatum.newInteger(2n));

      expect(data.get(Serialization.TransactionMetadatum.newList(list2))).toEqual(
        Serialization.TransactionMetadatum.newInteger(2n)
      );

      expect(data.get(Serialization.TransactionMetadatum.newList(list3))).toBeUndefined();
    });

    it('can find an element in a metadatum map with key - MetadatumMap', () => {
      const data = new Serialization.MetadatumMap();

      const map1 = new Serialization.MetadatumMap();
      const list1 = new Serialization.MetadatumList();
      list1.add(Serialization.TransactionMetadatum.newInteger(1n));
      list1.add(Serialization.TransactionMetadatum.newInteger(2n));
      list1.add(Serialization.TransactionMetadatum.newInteger(5n));
      map1.insert(Serialization.TransactionMetadatum.newList(list1), Serialization.TransactionMetadatum.newInteger(1n));

      const map2 = new Serialization.MetadatumMap();
      const list2 = new Serialization.MetadatumList();
      list2.add(Serialization.TransactionMetadatum.newInteger(1n));
      list2.add(Serialization.TransactionMetadatum.newInteger(2n));
      list2.add(Serialization.TransactionMetadatum.newInteger(5n));
      map2.insert(Serialization.TransactionMetadatum.newList(list2), Serialization.TransactionMetadatum.newInteger(1n));

      const map3 = new Serialization.MetadatumMap();
      const list3 = new Serialization.MetadatumList();
      list3.add(Serialization.TransactionMetadatum.newInteger(1n));
      list3.add(Serialization.TransactionMetadatum.newInteger(2n));
      map3.insert(Serialization.TransactionMetadatum.newList(list3), Serialization.TransactionMetadatum.newInteger(1n));

      data.insert(Serialization.TransactionMetadatum.newMap(map1), Serialization.TransactionMetadatum.newInteger(1n));

      expect(data.get(Serialization.TransactionMetadatum.newMap(map2))).toEqual(
        Serialization.TransactionMetadatum.newInteger(2n)
      );
      expect(data.get(Serialization.TransactionMetadatum.newMap(map3))).toBeUndefined();
    });
  });

  describe('Deep equality', () => {
    it('Integer', () => {
      expect(
        Serialization.TransactionMetadatum.newInteger(1n).equals(Serialization.TransactionMetadatum.newInteger(1n))
      ).toBeTruthy();
      expect(
        Serialization.TransactionMetadatum.newInteger(1n).equals(Serialization.TransactionMetadatum.newInteger(2n))
      ).toBeFalsy();
    });

    it('Text', () => {
      expect(
        Serialization.TransactionMetadatum.newText('some').equals(Serialization.TransactionMetadatum.newText('some'))
      ).toBeTruthy();
      expect(
        Serialization.TransactionMetadatum.newText('some').equals(Serialization.TransactionMetadatum.newText('more'))
      ).toBeFalsy();
    });

    it('Bytes', () => {
      expect(
        Serialization.TransactionMetadatum.newBytes(new Uint8Array([0, 1, 2])).equals(
          Serialization.TransactionMetadatum.newBytes(new Uint8Array([0, 1, 2]))
        )
      ).toBeTruthy();
      expect(
        Serialization.TransactionMetadatum.newBytes(new Uint8Array([0, 1, 2])).equals(
          Serialization.TransactionMetadatum.newBytes(new Uint8Array([0, 1]))
        )
      ).toBeFalsy();
    });

    it('MetadatumList', () => {
      const list1 = new Serialization.MetadatumList();
      list1.add(Serialization.TransactionMetadatum.newInteger(1n));
      list1.add(Serialization.TransactionMetadatum.newInteger(2n));
      list1.add(Serialization.TransactionMetadatum.newInteger(5n));

      const list2 = new Serialization.MetadatumList();
      list2.add(Serialization.TransactionMetadatum.newInteger(1n));
      list2.add(Serialization.TransactionMetadatum.newInteger(2n));
      list2.add(Serialization.TransactionMetadatum.newInteger(5n));

      const list3 = new Serialization.MetadatumList();
      list3.add(Serialization.TransactionMetadatum.newInteger(1n));
      list3.add(Serialization.TransactionMetadatum.newInteger(2n));

      expect(list1.equals(list2)).toBeTruthy();
      expect(list1.equals(list3)).toBeFalsy();
    });

    it('MetadatumMap', () => {
      const map1 = new Serialization.MetadatumMap();
      const list1 = new Serialization.MetadatumList();
      list1.add(Serialization.TransactionMetadatum.newInteger(1n));
      list1.add(Serialization.TransactionMetadatum.newInteger(2n));
      list1.add(Serialization.TransactionMetadatum.newInteger(5n));
      map1.insert(Serialization.TransactionMetadatum.newList(list1), Serialization.TransactionMetadatum.newInteger(1n));

      const map2 = new Serialization.MetadatumMap();
      const list2 = new Serialization.MetadatumList();
      list2.add(Serialization.TransactionMetadatum.newInteger(1n));
      list2.add(Serialization.TransactionMetadatum.newInteger(2n));
      list2.add(Serialization.TransactionMetadatum.newInteger(5n));
      map2.insert(Serialization.TransactionMetadatum.newList(list2), Serialization.TransactionMetadatum.newInteger(1n));

      const map3 = new Serialization.MetadatumMap();
      const list3 = new Serialization.MetadatumList();
      list3.add(Serialization.TransactionMetadatum.newInteger(1n));
      list3.add(Serialization.TransactionMetadatum.newInteger(2n));
      map3.insert(Serialization.TransactionMetadatum.newList(list3), Serialization.TransactionMetadatum.newInteger(1n));

      expect(map1.equals(map2)).toBeTruthy();
      expect(map1.equals(map3)).toBeFalsy();
    });
  });
});
