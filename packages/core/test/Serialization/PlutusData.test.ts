/* eslint-disable max-len */
import { Cardano, Serialization } from '../../src';
import { HexBlob } from '@cardano-sdk/util';

describe('PlutusData', () => {
  it('round trip serializations produce the same core type output', () => {
    const plutusData: Cardano.PlutusData = 123n;
    const fromCore = Serialization.PlutusData.fromCore(plutusData);
    const cbor = fromCore.toCbor();
    const fromCbor = Serialization.PlutusData.fromCbor(cbor);
    expect(fromCbor.toCore()).toEqual(plutusData);
  });

  it('converts (TODO: describe is special about this that fails) inline datum', () => {
    // tx: https://preprod.cexplorer.io/tx/32d2b9062680c7ef5673114abce804d8b854f54440518e48a6db3e555f3a84d2
    // parsed datum: https://preprod.cexplorer.io/datum/f20e5a0a42a9015cd4e53f8b8c020e535957f782ea3231453fe4cf46a52d07c9
    const cbor = HexBlob(
      'd8799fa3446e616d6548537061636542756445696d6167654b697066733a2f2f7465737445696d616765583061723a2f2f66355738525a6d4151696d757a5f7679744659396f66497a6439517047614449763255587272616854753401ff'
    );
    expect(() => Serialization.PlutusData.fromCbor(cbor)).not.toThrowError();
  });

  it('can compute correct hash', () => {
    const data = Serialization.PlutusData.fromCbor(HexBlob('46010203040506'));

    // Hash was generated with the CSL
    expect(data.hash()).toEqual('f5e45fd57d6c5591dd9e83e76943827c4f4a9eacefd5ac974f48afd8420765a6');
  });

  describe('Integer', () => {
    it('can encode a positive integer', () => {
      const data = Serialization.PlutusData.newInteger(5n);
      expect(data.toCbor()).toEqual('05');
    });

    it('can encode a negative integer', () => {
      const data = Serialization.PlutusData.newInteger(-5n);
      expect(data.toCbor()).toEqual('24');
    });

    it('can encode an integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.newInteger(18_446_744_073_709_551_616n);
      expect(data.toCbor()).toEqual('c249010000000000000000');
    });

    it('can encode a negative integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.newInteger(-18_446_744_073_709_551_616n);
      expect(data.toCbor()).toEqual('3bffffffffffffffff');
    });

    it('can decode a positive integer', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('05'));
      expect(data.asInteger()).toEqual(5n);
    });

    it('can decode a negative integer', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('24'));
      expect(data.asInteger()).toEqual(-5n);
    });

    it('can decode an integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('c249010000000000000000'));
      expect(data.asInteger()).toEqual(18_446_744_073_709_551_616n);
    });

    it('can decode a negative integer bigger than unsigned 64bits', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('3bffffffffffffffff'));
      expect(data.asInteger()).toEqual(-18_446_744_073_709_551_616n);
    });

    it('can decode a positive tagged indefinite length unbounded int', () => {
      const data = Serialization.PlutusData.fromCbor(
        HexBlob(
          'c25f584037d34fac60a7dd2edba0c76fa58862c91c45ff4298e9134ba8e76be9a7513d88865bfdb9315073dc2690b0f2b59a232fbfa0a8a504df6ee9bb78e3f33fbdfef95529c9e74ff30ffe1bd1cc5795c37535899dba800000ff'
        )
      );
      expect(data.asInteger()).toEqual(
        // eslint-disable-next-line max-len
        1_093_929_156_918_367_016_766_069_563_027_239_416_446_778_893_307_251_997_971_794_948_729_105_062_347_369_330_146_869_223_033_199_554_831_433_128_491_376_164_494_134_119_896_793_625_745_623_928_731_109_781_036_903_510_617_119_765_359_815_723_399_113_165_600_284_443_934_720n
      );
    });
  });

  describe('Bytes', () => {
    it('can encode a small byte string (less than 64 bytes)', () => {
      const data = Serialization.PlutusData.newBytes(new Uint8Array([0x01, 0x02, 0x03, 0x04, 0x05, 0x06]));
      expect(data.toCbor()).toEqual('46010203040506');
    });

    it('can decode a small byte string (less than 64 bytes)', () => {
      const data = Serialization.PlutusData.fromCbor(HexBlob('46010203040506'));
      expect(HexBlob.fromBytes(data.asBoundedBytes()!)).toEqual('010203040506');
    });

    it('can encode a big byte string (more than 64 bytes)', () => {
      const payload = new Uint8Array([
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08
      ]);

      const data = Serialization.PlutusData.newBytes(payload);
      expect(data.toCbor()).toEqual(
        '5f584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708ff'
      );
    });

    it('can decode a big byte string (more than 64 bytes)', () => {
      const payload = [
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
        0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02,
        0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08
      ];

      const data = Serialization.PlutusData.fromCbor(
        HexBlob(
          '5f584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708584001020304050607080102030405060708010203040506070801020304050607080102030405060708010203040506070801020304050607080102030405060708ff'
        )
      );
      expect([...data.asBoundedBytes()!]).toEqual(payload);
    });

    it('can decode/encode a list of big integers', () => {
      // Arrange

      const expectedPlutusData: Cardano.PlutusList = {
        items: [
          1_093_929_156_918_367_016_766_069_563_027_239_416_446_778_893_307_251_997_971_794_948_729_105_062_347_369_330_146_869_223_033_199_554_831_433_128_491_376_164_494_134_119_896_793_625_745_623_928_731_109_781_036_903_510_617_119_765_359_815_723_399_113_165_600_284_443_934_720n,
          2_768_491_094_397_106_413_284_351_268_798_781_278_061_973_163_918_667_373_508_176_781_108_678_876_832_888_565_950_388_553_255_499_815_619_207_549_146_245_084_281_150_783_450_096_035_638_439_655_721_496_227_482_399_093_555_200_000_000_000_000_000_000_000_000_000_000_000_000n,
          2_768_491_094_397_106_413_284_351_268_798_781_278_061_973_163_918_667_373_508_176_781_108_678_876_832_888_565_950_388_553_255_499_815_619_207_549_146_245_084_281_150_783_450_096_035_638_439_655_721_496_227_482_399_093_555_200_000_000_000_000_000_000_000_000_000_000_000_000n,
          1_127_320_948_699_467_529_606_464_548_687_160_198_167_487_105_208_190_997_153_720_362_564_942_186_550_892_230_582_242_980_573_812_448_057_150_419_530_802_096_156_402_677_128_058_112_319_272_573_039_196_273_296_535_693_983_366_369_964_092_325_725_072_645_646_768_416_006_720n,
          678_966_618_629_088_994_577_385_052_394_593_905_048_788_216_453_653_741_455_475_012_343_328_029_630_393_478_083_358_655_655_534_689_789_017_294_468_365_725_065_895_808_744_013_442_165_812_351_180_871_208_842_081_615_673_249_725_577_503_335_455_257_844_242_272_891_195_840n,
          1_337_829_155_615_373_710_780_861_189_358_723_839_738_261_900_670_472_008_493_768_766_460_943_065_914_931_970_040_774_692_071_540_815_257_661_221_428_415_268_570_880_739_215_388_841_910_028_989_315_213_224_986_535_176_632_464_067_341_466_233_795_236_134_699_058_357_952_960n,
          45_981_213_582_240_091_300_385_870_382_262_347_274_104_141_060_516_509_284_758_089_043_905_194_449_918_733_499_912_740_694_341_485_053_723_341_097_850_038_365_519_925_374_324_306_213_051_881_991_025_304_309_829_953_615_052_414_155_047_559_800_693_983_587_151_987_253_760n,
          2_413_605_787_847_473_064_058_493_109_882_761_763_812_632_923_885_676_112_901_376_523_745_345_875_592_342_323_079_462_001_682_936_368_998_782_686_824_629_943_810_471_167_748_859_099_323_567_551_094_056_876_663_897_197_968_204_837_564_889_906_128_763_937_156_053n
        ]
      };

      const expectedCbor = HexBlob(
        '9fc25f584037d34fac60a7dd2edba0c76fa58862c91c45ff4298e9134ba8e76be9a7513d88865bfdb9315073dc2690b0f2b59a232fbfa0a8a504df6ee9bb78e3f33fbdfef95529c9e74ff30ffe1bd1cc5795c37535899dba800000ffc25f58408d4820519e9bba2d6556c87b100709082f4c8958769899eb5d288b6f9ea9e0723df7211959860edea5829c9732422d25962e3945c68a6089f50a18b0114248b7555feea4851e9f099180600000000000000000000000ffc25f58408d4820519e9bba2d6556c87b100709082f4c8958769899eb5d288b6f9ea9e0723df7211959860edea5829c9732422d25962e3945c68a6089f50a18b0114248b7555feea4851e9f099180600000000000000000000000ffc25f584039878c5f4d4063e9a2ee75a3fbdd1492c3cad46f4ecbae977ac94b709a730e367edf9dae05acd59638d1dec25e2351c2eecb871694afae979de7085b522efe1355634138bbd920200d574cdf400324cdd1aafe10a240ffc25f584022a6282a7d960570c4c729decd677ec617061f0e501249c41f8724c89dc97dc0d24917bdb7a7ebd7c079c1c56fa21af0f119168966356ea384fb711cb766015e55bfc5bc86583f6a82ae605a93e7bf974ae74cd051c0ffc25f58404445ab8649611ee8f74a3c31e504a2f25f2f7631ef6ef828a405542904d84c997304b1b332d528ee54873b03cfb73cd3c5b35b91184f6846afccec7271bda8a05563ba46aed8c82611da47fd608d027447f8391161c0ffc25f58400258b535c4d4a22a483b22b2f5c5c65bed9e7de59266f6bbaa8997edf5bec6bb5d203641bb58d8ade1a3a5b4e5f923df502cf1e47691865fe1984eacef3be96a551ed585e070265db203a8866726bed053cb6c8aa200ffc25f5840021104310667ec434e9e2cd9fa71853593c42e1b55865ac49f80b2ea22beeec9b4a55e9545055a2bcde3a78d36836df11df0f91c1dae9a8aee58419b8650bc6c529361f9601a4005051b045d05f39a5f00ebd5ffff'
      );

      // Act
      const actualPlutusData = Serialization.PlutusData.fromCbor(expectedCbor);
      const actualCbor = Serialization.PlutusData.fromCore(expectedPlutusData).toCbor();

      // Assert
      expect((actualPlutusData.toCore() as Cardano.PlutusList).items).toEqual(expectedPlutusData.items);
      expect(actualCbor).toEqual(expectedCbor);
    });
  });

  describe('List', () => {
    it('can encode an empty plutus list', () => {
      const data = new Serialization.PlutusList();

      expect(data.toCbor()).toEqual('80');
    });

    it('can encode simple plutus list', () => {
      const data = new Serialization.PlutusList();

      data.add(Serialization.PlutusData.newInteger(1n));
      data.add(Serialization.PlutusData.newInteger(2n));
      data.add(Serialization.PlutusData.newInteger(3n));
      data.add(Serialization.PlutusData.newInteger(4n));
      data.add(Serialization.PlutusData.newInteger(5n));

      expect(data.toCbor()).toEqual('9f0102030405ff');
    });

    it('can encode a list of plutus list', () => {
      const innerList = new Serialization.PlutusList();

      innerList.add(Serialization.PlutusData.newInteger(1n));
      innerList.add(Serialization.PlutusData.newInteger(2n));
      innerList.add(Serialization.PlutusData.newInteger(3n));
      innerList.add(Serialization.PlutusData.newInteger(4n));
      innerList.add(Serialization.PlutusData.newInteger(5n));

      const outer = new Serialization.PlutusList();

      outer.add(Serialization.PlutusData.newInteger(1n));
      outer.add(Serialization.PlutusData.newInteger(2n));
      outer.add(Serialization.PlutusData.newList(innerList));
      outer.add(Serialization.PlutusData.newList(innerList));
      outer.add(Serialization.PlutusData.newInteger(5n));

      expect(outer.toCbor()).toEqual('9f01029f0102030405ff9f0102030405ff05ff');
    });
  });

  describe('Map', () => {
    it('can encode simple plutus map', () => {
      const data = new Serialization.PlutusMap();

      data.insert(Serialization.PlutusData.newInteger(1n), Serialization.PlutusData.newInteger(2n));

      expect(data.toCbor()).toEqual('a10102');
    });

    it('can find an element in a plutus map with key - Integer', () => {
      const data = new Serialization.PlutusMap();

      data.insert(Serialization.PlutusData.newInteger(1n), Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newInteger(1n))).toEqual(Serialization.PlutusData.newInteger(2n));
      expect(data.get(Serialization.PlutusData.newInteger(2n))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - Bytes', () => {
      const data = new Serialization.PlutusMap();

      data.insert(
        Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])),
        Serialization.PlutusData.newInteger(2n)
      );

      expect(data.get(Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])))).toEqual(
        Serialization.PlutusData.newInteger(2n)
      );

      expect(data.get(Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2, 3])))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - PlutusList', () => {
      const data = new Serialization.PlutusMap();

      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));

      data.insert(Serialization.PlutusData.newList(list1), Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newList(list2))).toEqual(Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newList(list3))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - PlutusMap', () => {
      const data = new Serialization.PlutusMap();

      const map1 = new Serialization.PlutusMap();
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));
      map1.insert(Serialization.PlutusData.newList(list1), Serialization.PlutusData.newInteger(1n));

      const map2 = new Serialization.PlutusMap();
      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));
      map2.insert(Serialization.PlutusData.newList(list2), Serialization.PlutusData.newInteger(1n));

      const map3 = new Serialization.PlutusMap();
      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      map3.insert(Serialization.PlutusData.newList(list3), Serialization.PlutusData.newInteger(1n));

      data.insert(Serialization.PlutusData.newMap(map1), Serialization.PlutusData.newInteger(1n));

      expect(data.get(Serialization.PlutusData.newMap(map2))).toEqual(Serialization.PlutusData.newInteger(2n));
      expect(data.get(Serialization.PlutusData.newMap(map3))).toBeUndefined();
    });

    it('can find an element in a plutus map with key - Constr', () => {
      const data = new Serialization.PlutusMap();

      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(3n));
      const constr1 = new Serialization.ConstrPlutusData(0n, list1);

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(3n));
      const constr2 = new Serialization.ConstrPlutusData(0n, list2);

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      const constr3 = new Serialization.ConstrPlutusData(1n, list2);

      data.insert(Serialization.PlutusData.newConstrPlutusData(constr1), Serialization.PlutusData.newInteger(2n));

      expect(data.get(Serialization.PlutusData.newConstrPlutusData(constr2))).toEqual(
        Serialization.PlutusData.newInteger(2n)
      );
      expect(data.get(Serialization.PlutusData.newConstrPlutusData(constr3))).toBeUndefined();
    });
  });

  describe('Constr', () => {
    it('can encode simple Constr', () => {
      const args = new Serialization.PlutusList();
      args.add(Serialization.PlutusData.newInteger(1n));
      args.add(Serialization.PlutusData.newInteger(2n));
      args.add(Serialization.PlutusData.newInteger(3n));
      args.add(Serialization.PlutusData.newInteger(4n));
      args.add(Serialization.PlutusData.newInteger(5n));

      const data = new Serialization.ConstrPlutusData(0n, args);

      expect(data.toCbor()).toEqual('d8799f0102030405ff');
    });
  });

  describe('Deep equality', () => {
    it('Integer', () => {
      expect(Serialization.PlutusData.newInteger(1n).equals(Serialization.PlutusData.newInteger(1n))).toBeTruthy();
      expect(Serialization.PlutusData.newInteger(1n).equals(Serialization.PlutusData.newInteger(2n))).toBeFalsy();
    });

    it('Bytes', () => {
      expect(
        Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])).equals(
          Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2]))
        )
      ).toBeTruthy();
      expect(
        Serialization.PlutusData.newBytes(new Uint8Array([0, 1, 2])).equals(
          Serialization.PlutusData.newBytes(new Uint8Array([0, 1]))
        )
      ).toBeFalsy();
    });

    it('PlutusList', () => {
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));

      expect(list1.equals(list2)).toBeTruthy();
      expect(list1.equals(list3)).toBeFalsy();
    });

    it('PlutusMap', () => {
      const map1 = new Serialization.PlutusMap();
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(5n));
      map1.insert(Serialization.PlutusData.newList(list1), Serialization.PlutusData.newInteger(1n));

      const map2 = new Serialization.PlutusMap();
      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(5n));
      map2.insert(Serialization.PlutusData.newList(list2), Serialization.PlutusData.newInteger(1n));

      const map3 = new Serialization.PlutusMap();
      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      map3.insert(Serialization.PlutusData.newList(list3), Serialization.PlutusData.newInteger(1n));

      expect(map1.equals(map2)).toBeTruthy();
      expect(map1.equals(map3)).toBeFalsy();
    });

    it('Constr', () => {
      const list1 = new Serialization.PlutusList();
      list1.add(Serialization.PlutusData.newInteger(1n));
      list1.add(Serialization.PlutusData.newInteger(2n));
      list1.add(Serialization.PlutusData.newInteger(3n));
      const constr1 = new Serialization.ConstrPlutusData(0n, list1);

      const list2 = new Serialization.PlutusList();
      list2.add(Serialization.PlutusData.newInteger(1n));
      list2.add(Serialization.PlutusData.newInteger(2n));
      list2.add(Serialization.PlutusData.newInteger(3n));
      const constr2 = new Serialization.ConstrPlutusData(0n, list2);

      const list3 = new Serialization.PlutusList();
      list3.add(Serialization.PlutusData.newInteger(1n));
      list3.add(Serialization.PlutusData.newInteger(2n));
      const constr3 = new Serialization.ConstrPlutusData(1n, list2);

      expect(constr1.equals(constr2)).toBeTruthy();
      expect(constr1.equals(constr3)).toBeFalsy();
    });
  });
});
