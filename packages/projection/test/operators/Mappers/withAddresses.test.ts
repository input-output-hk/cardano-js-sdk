import { Cardano } from '@cardano-sdk/core';
import { ProducedUtxo, WithUtxo } from '../../../src/operators/Mappers';
import { ProjectionEvent } from '../../../src';
import { cip19TestVectors, generateRandomHexString } from '@cardano-sdk/util-dev';
import { firstValueFrom, of } from 'rxjs';
import { withAddresses } from '../../../src/operators/Mappers/withAddresses';

const projectEvent = async (addresses: Cardano.PaymentAddress[]) => {
  const producedOutputs = addresses.map(
    (address): ProducedUtxo => [
      { index: 0, txId: Cardano.TransactionId(generateRandomHexString(64)) },
      { address, value: { coins: 123n } }
    ]
  );
  const event = {
    utxo: {
      produced: producedOutputs
    },
    utxoByTx: {
      [Cardano.TransactionId(generateRandomHexString(64))]: {
        produced: producedOutputs
      }
    }
  } as ProjectionEvent<WithUtxo>;
  return firstValueFrom(of(event).pipe(withAddresses()));
};

describe('withAddresses', () => {
  it('maps both payment and stake credential for base/grouped addresses', async () => {
    const addresses = [
      cip19TestVectors.basePaymentKeyStakeKey,
      cip19TestVectors.basePaymentKeyStakeScript,
      cip19TestVectors.basePaymentScriptStakeKey,
      cip19TestVectors.basePaymentScriptStakeScript
    ];
    const mappedEvent = await projectEvent(addresses);
    expect(mappedEvent.addresses).toEqual([
      {
        address: addresses[0],
        paymentCredentialHash: cip19TestVectors.PAYMENT_KEY_HASH,
        stakeCredential: cip19TestVectors.STAKE_KEY_HASH,
        type: Cardano.AddressType.BasePaymentKeyStakeKey
      },
      {
        address: addresses[1],
        paymentCredentialHash: cip19TestVectors.PAYMENT_KEY_HASH,
        stakeCredential: cip19TestVectors.SCRIPT_HASH,
        type: Cardano.AddressType.BasePaymentKeyStakeScript
      },
      {
        address: addresses[2],
        paymentCredentialHash: cip19TestVectors.SCRIPT_HASH,
        stakeCredential: cip19TestVectors.STAKE_KEY_HASH,
        type: Cardano.AddressType.BasePaymentScriptStakeKey
      },
      {
        address: addresses[3],
        paymentCredentialHash: cip19TestVectors.SCRIPT_HASH,
        stakeCredential: cip19TestVectors.SCRIPT_HASH,
        type: Cardano.AddressType.BasePaymentScriptStakeScript
      }
    ]);
  });

  it('maps payment credential for enterprise addresses', async () => {
    const addresses = [cip19TestVectors.enterpriseKey, cip19TestVectors.enterpriseScript];
    const mappedEvent = await projectEvent(addresses);
    expect(mappedEvent.addresses).toEqual([
      {
        address: addresses[0],
        paymentCredentialHash: cip19TestVectors.PAYMENT_KEY_HASH,
        type: Cardano.AddressType.EnterpriseKey
      },
      {
        address: addresses[1],
        paymentCredentialHash: cip19TestVectors.SCRIPT_HASH,
        type: Cardano.AddressType.EnterpriseScript
      }
    ]);
  });

  it('maps payment and stake credential for pointer addresses', async () => {
    const addresses = [cip19TestVectors.pointerKey, cip19TestVectors.pointerScript];
    const mappedEvent = await projectEvent(addresses);
    expect(mappedEvent.addresses).toEqual([
      {
        address: addresses[0],
        paymentCredentialHash: cip19TestVectors.PAYMENT_KEY_HASH,
        stakeCredential: cip19TestVectors.POINTER,
        type: Cardano.AddressType.PointerKey
      },
      {
        address: addresses[1],
        paymentCredentialHash: cip19TestVectors.SCRIPT_HASH,
        stakeCredential: cip19TestVectors.POINTER,
        type: Cardano.AddressType.PointerScript
      }
    ]);
  });

  it('maps byron addresses without any credentials', async () => {
    const addresses = [cip19TestVectors.byronMainnetYoroi, cip19TestVectors.byronTestnetDaedalus];
    const mappedEvent = await projectEvent(addresses);
    expect(mappedEvent.addresses).toEqual([
      {
        address: addresses[0],
        type: Cardano.AddressType.Byron
      },
      {
        address: addresses[1],
        type: Cardano.AddressType.Byron
      }
    ]);
  });
});
