import { Buffer } from 'buffer';
import { Cardano, cmlToCore, coreToCml, metadatum } from '@cardano-sdk/core';
import { TxMetadataModel, mapTxMetadata } from '../../src/Metadata';
import { usingAutoFree } from '@cardano-sdk/util';

const toBytes = (data: Cardano.Metadatum) => usingAutoFree((scope) => coreToCml.txMetadatum(scope, data).to_bytes());

describe('mapTxMetadata', () => {
  it('maps TxMetadataModel to Cardano.TxMetadata', () => {
    const transactionHash = 'cefd2fcf657e5e5d6c35975f4e052f427819391b153ebb16ad8aa107ba5a3819';
    const txMetadataModel: TxMetadataModel[] = [
      {
        bytes: toBytes(new Map([[127n, metadatum.jsonToMetadatum({ v: 1 })]])),
        key: '127',
        tx_id: Buffer.from(transactionHash, 'hex')
      },
      {
        bytes: toBytes(new Map([[500n, metadatum.jsonToMetadatum({ a: 2 })]])),
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

  it('ignores non-metadata objects (with no metadata "key")', () => {
    expect(mapTxMetadata([{ bytes: toBytes(new Map([[127n, '']])), key: '' }])).toEqual(new Map());
  });

  it('ignores non-metadata objects (with no metadata "bytes")', () => {
    expect(mapTxMetadata([{ bytes: null as unknown as Uint8Array, key: '123' }])).toEqual(new Map());
  });

  it('throws if non-metadata objects (with metadata "bytes" which is not a Map)', () => {
    expect(() => mapTxMetadata([{ bytes: toBytes('test'), key: '123' }])).toThrow();
  });

  it('ignores non-metadata objects (with metadata "bytes" which is a Map but doesn\'t contain key)', () => {
    expect(mapTxMetadata([{ bytes: toBytes(new Map([[127n, '']])), key: '123' }])).toEqual(new Map());
  });

  it('throws if key cannot be parse to bigint', () => {
    expect(() => mapTxMetadata([{ bytes: toBytes('test'), key: 'bad' }])).toThrow();
  });

  it.skip('uses cmlToCore.txMetadatum to map bytes', () => {
    const bytes = toBytes(new Map([[127n, 'test']]));
    const spy = jest.spyOn(cmlToCore, 'txMetadatum');
    spy.mockReset();

    mapTxMetadata([{ bytes, key: '127' }]);
    expect(spy).toBeCalledTimes(1);
    expect(spy).toBeCalledWith(bytes);
  });
});
