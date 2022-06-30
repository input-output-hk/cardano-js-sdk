import { Cardano, ProviderUtil } from '@cardano-sdk/core';
import { TxMetadataModel, mapTxMetadata } from '../../src/Metadata';

describe('mapTxMetadata', () => {
  it('maps TxMetadataModel to Cardano.TxMetadata', () => {
    const transactionHash = 'cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819';
    const txMetadataModel: TxMetadataModel[] = [
      {
        json_value: { v: 1 },
        key: '127',
        tx_id: Buffer.from(transactionHash, 'hex')
      },
      {
        json_value: { a: 2 },
        key: '500',
        tx_id: Buffer.from(transactionHash, 'hex')
      }
    ];
    const result = mapTxMetadata(txMetadataModel);
    expect(result).toEqual<Cardano.TxMetadata>(
      new Map([
        [127n, new Map([['v', 1n]])],
        [500n, new Map([['a', 2n]])]
      ])
    );
  });

  it('no metadata returns an empty metadata map', () => {
    expect(mapTxMetadata([])).toEqual(new Map());
  });

  it('ignores non-metadata objects (with no metadata "key" or "json_value")', () => {
    expect(mapTxMetadata([{ json_value: { a: 1 }, key: '' }])).toEqual(new Map());
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(mapTxMetadata([{ json_value: null, key: '123' } as any])).toEqual(new Map());
  });

  it('throws if key cannot be parse to bigint', () => {
    expect(() => mapTxMetadata([{ json_value: { a: 1 }, key: 'bad' }])).toThrow();
  });

  it('uses ProviderUtil.jsonToMetadata to map json_value', () => {
    const spy = jest.spyOn(ProviderUtil, 'jsonToMetadatum');
    spy.mockReset();
    const json_value = { a: 1 };
    mapTxMetadata([{ json_value, key: '123' }]);
    expect(spy).toBeCalledTimes(1);
    expect(spy).toBeCalledWith(json_value);
  });
});
