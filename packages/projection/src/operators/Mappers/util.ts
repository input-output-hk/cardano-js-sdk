import { Address } from './withAddresses';
import { Asset, Cardano, Handle } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Logger } from 'ts-log';

/** Up to 100k transactions per block. Fits in 64-bit signed integer. */
export const computeCompactTxId = (blockHeight: number, txIndex: number) => blockHeight * 100_000 + txIndex;

export const assetNameToUTF8Handle = (assetName: Cardano.AssetName, logger: Logger): Handle | null => {
  const handle = Cardano.AssetName.toUTF8(assetName);
  if (!Asset.util.isValidHandle(handle)) {
    logger.warn(`Invalid handle: '${handle}' / '${assetName}'`);
    return null;
  }
  return handle;
};

export const credentialsFromAddress = (address: Cardano.PaymentAddress): Address => {
  const parsed = Cardano.Address.fromString(address)!;
  let paymentCredentialHash: Hash28ByteBase16 | undefined;
  let stakeCredentialHash: Hash28ByteBase16 | undefined;
  let pointer: Cardano.Pointer | undefined;
  const type = parsed.getType();
  switch (type) {
    case Cardano.AddressType.BasePaymentKeyStakeKey:
    case Cardano.AddressType.BasePaymentKeyStakeScript:
    case Cardano.AddressType.BasePaymentScriptStakeKey:
    case Cardano.AddressType.BasePaymentScriptStakeScript: {
      const baseAddress = parsed.asBase()!;
      paymentCredentialHash = baseAddress.getPaymentCredential().hash;
      stakeCredentialHash = baseAddress.getStakeCredential().hash;
      break;
    }
    case Cardano.AddressType.EnterpriseKey:
    case Cardano.AddressType.EnterpriseScript: {
      const enterpriseAddress = parsed.asEnterprise()!;
      paymentCredentialHash = enterpriseAddress.getPaymentCredential().hash;
      break;
    }
    case Cardano.AddressType.PointerKey:
    case Cardano.AddressType.PointerScript: {
      const pointerAddress = parsed.asPointer()!;
      paymentCredentialHash = pointerAddress.getPaymentCredential().hash;
      pointer = pointerAddress.getStakePointer();
      break;
    }
  }
  return {
    address,
    paymentCredentialHash,
    stakeCredential: stakeCredentialHash || pointer,
    type
  };
};
