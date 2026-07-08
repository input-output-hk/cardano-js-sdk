import { Cardano } from '../../../src';
import { HexBlob, InvalidArgumentError } from '@cardano-sdk/util';
import { ProtocolParamUpdate } from '../../../src/Serialization/Update/ProtocolParamUpdate';
import { UnitInterval } from '../../../src/Serialization/Common';

const MAX_WORD32 = 4_294_967_295;

const dijkstraCbor = HexBlob('a60018641821d81e8218590218221a004c4b4018231a000f424018241964001825d81e820302');

const subsetCbor = HexBlob('a218221a004c4b401825d81e820302');

const maxWord32Cbor = HexBlob('a318221affffffff18231affffffff18241affffffff');

const dijkstraCore: Cardano.ProtocolParametersUpdate = {
  maxRefScriptSizePerBlock: 5_000_000,
  maxRefScriptSizePerTx: 1_000_000,
  minFeeCoefficient: 100,
  minFeeRefScriptCostPerByte: '44.5',
  refScriptCostMultiplier: '1.5',
  refScriptCostStride: 25_600
};

const subsetCore: Cardano.ProtocolParametersUpdate = {
  maxRefScriptSizePerBlock: 5_000_000,
  refScriptCostMultiplier: '1.5'
};

describe('ProtocolParamUpdate Dijkstra params', () => {
  it('can decode keys 34-37 from CBOR', () => {
    const params = ProtocolParamUpdate.fromCbor(dijkstraCbor);

    expect(params.minFeeA()).toEqual(100n);
    expect(params.minFeeRefScriptCostPerByte()?.toFloat()).toEqual(44.5);
    expect(params.maxRefScriptSizePerBlock()).toEqual(5_000_000);
    expect(params.maxRefScriptSizePerTx()).toEqual(1_000_000);
    expect(params.refScriptCostStride()).toEqual(25_600);
    expect(params.refScriptCostMultiplier()?.toFloat()).toEqual(1.5);
  });

  it('round trips CBOR with all four new keys byte-exact', () => {
    expect(ProtocolParamUpdate.fromCbor(dijkstraCbor).toCbor()).toEqual(dijkstraCbor);
    expect(ProtocolParamUpdate.fromCore(dijkstraCore).toCbor()).toEqual(dijkstraCbor);
  });

  it('round trips CBOR with only a subset of the new keys byte-exact', () => {
    const params = ProtocolParamUpdate.fromCbor(subsetCbor);

    expect(params.maxRefScriptSizePerBlock()).toEqual(5_000_000);
    expect(params.maxRefScriptSizePerTx()).toBeUndefined();
    expect(params.refScriptCostStride()).toBeUndefined();
    expect(params.refScriptCostMultiplier()?.toFloat()).toEqual(1.5);
    expect(params.toCbor()).toEqual(subsetCbor);
    expect(ProtocolParamUpdate.fromCore(subsetCore).toCbor()).toEqual(subsetCbor);
  });

  it('omits keys 34-37 when the fields are not set', () => {
    expect(ProtocolParamUpdate.fromCore({ minFeeCoefficient: 100 }).toCbor()).toEqual(HexBlob('a1001864'));
  });

  it('converts to core with the new fields', () => {
    expect(ProtocolParamUpdate.fromCbor(dijkstraCbor).toCore()).toEqual(dijkstraCore);
  });

  it('is symmetric between toCore and fromCore', () => {
    expect(ProtocolParamUpdate.fromCore(dijkstraCore).toCore()).toEqual(dijkstraCore);
    expect(ProtocolParamUpdate.fromCore(subsetCore).toCore()).toEqual(subsetCore);
  });

  it('can set and encode the new fields at the uint32 upper bound', () => {
    const params = new ProtocolParamUpdate();

    params.setMaxRefScriptSizePerBlock(MAX_WORD32);
    params.setMaxRefScriptSizePerTx(MAX_WORD32);
    params.setRefScriptCostStride(MAX_WORD32);

    expect(params.maxRefScriptSizePerBlock()).toEqual(MAX_WORD32);
    expect(params.maxRefScriptSizePerTx()).toEqual(MAX_WORD32);
    expect(params.refScriptCostStride()).toEqual(MAX_WORD32);
    expect(params.toCbor()).toEqual(maxWord32Cbor);
  });

  it('can set the multiplier through the setter', () => {
    const params = new ProtocolParamUpdate();

    params.setRefScriptCostMultiplier(new UnitInterval(3n, 2n));

    expect(params.refScriptCostMultiplier()?.toFloat()).toEqual(1.5);
    expect(params.toCbor()).toEqual(HexBlob('a11825d81e820302'));
  });

  it('rejects values greater than the uint32 upper bound', () => {
    const params = new ProtocolParamUpdate();

    expect(() => params.setMaxRefScriptSizePerBlock(MAX_WORD32 + 1)).toThrow(InvalidArgumentError);
    expect(() => params.setMaxRefScriptSizePerTx(MAX_WORD32 + 1)).toThrow(InvalidArgumentError);
    expect(() => params.setRefScriptCostStride(MAX_WORD32 + 1)).toThrow(InvalidArgumentError);
  });

  it('rejects a zero cost stride', () => {
    const params = new ProtocolParamUpdate();

    expect(() => params.setRefScriptCostStride(0)).toThrow(InvalidArgumentError);
  });

  it('rejects a non positive cost multiplier', () => {
    const params = new ProtocolParamUpdate();

    expect(() => params.setRefScriptCostMultiplier(new UnitInterval(0n, 2n))).toThrow(InvalidArgumentError);
  });

  it('rejects out of range values when encoding fields set through fromCore', () => {
    expect(() => ProtocolParamUpdate.fromCore({ refScriptCostStride: 0 }).toCbor()).toThrow(InvalidArgumentError);
    expect(() => ProtocolParamUpdate.fromCore({ maxRefScriptSizePerBlock: MAX_WORD32 + 1 }).toCbor()).toThrow(
      InvalidArgumentError
    );
    expect(() => ProtocolParamUpdate.fromCore({ maxRefScriptSizePerTx: MAX_WORD32 + 1 }).toCbor()).toThrow(
      InvalidArgumentError
    );
    expect(() => ProtocolParamUpdate.fromCore({ refScriptCostStride: MAX_WORD32 + 1 }).toCbor()).toThrow(
      InvalidArgumentError
    );
  });
});
