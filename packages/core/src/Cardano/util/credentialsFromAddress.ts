import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Cardano } from '../..';

export const credentialsFromAddress = (address: Cardano.PaymentAddress) => {
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
    spendingCredentialHash: paymentCredentialHash,
    stakeCredential: stakeCredentialHash || pointer,
    type
  };
};
