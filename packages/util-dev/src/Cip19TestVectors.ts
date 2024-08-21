import { Cardano } from '@cardano-sdk/core';
import type { Hash28ByteBase16 } from '@cardano-sdk/crypto';

// Test vectors taken from https://cips.cardano.org/cips/cip19/#testvectors

export const PAYMENT_KEY_HASH = '9493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e';
export const STAKE_KEY_HASH = '337b62cfff6403a06a3acbc34f8c46003c69fe79a3628cefa9c47251';
export const SCRIPT_HASH = 'c37b1b5dc0669f1d3c61a6fddb2e8fde96be87b881c60bce8e8d542f';

export const KEY_PAYMENT_CREDENTIAL: Cardano.Credential = {
  hash: PAYMENT_KEY_HASH as Hash28ByteBase16,
  type: Cardano.CredentialType.KeyHash
};

export const KEY_STAKE_CREDENTIAL: Cardano.Credential = {
  hash: STAKE_KEY_HASH as Hash28ByteBase16,
  type: Cardano.CredentialType.KeyHash
};

export const SCRIPT_CREDENTIAL: Cardano.Credential = {
  hash: SCRIPT_HASH as Hash28ByteBase16,
  type: Cardano.CredentialType.ScriptHash
};

export const POINTER: Cardano.Pointer = {
  certIndex: Cardano.CertIndex(3),
  slot: 2_498_243n,
  txIndex: Cardano.TxIndex(27)
};

export const basePaymentKeyStakeKey =
  'addr1qx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3n0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgse35a3x' as Cardano.PaymentAddress;
export const basePaymentScriptStakeKey =
  'addr1z8phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gten0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgs9yc0hh' as Cardano.PaymentAddress;
export const basePaymentKeyStakeScript =
  'addr1yx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerkr0vd4msrxnuwnccdxlhdjar77j6lg0wypcc9uar5d2shs2z78ve' as Cardano.PaymentAddress;
export const basePaymentScriptStakeScript =
  'addr1x8phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gt7r0vd4msrxnuwnccdxlhdjar77j6lg0wypcc9uar5d2shskhj42g' as Cardano.PaymentAddress;
export const pointerKey =
  'addr1gx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer5pnz75xxcrzqf96k' as Cardano.PaymentAddress;
export const pointerScript =
  'addr128phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtupnz75xxcrtw79hu' as Cardano.PaymentAddress;
export const enterpriseKey = 'addr1vx2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzers66hrl8' as Cardano.PaymentAddress;
export const enterpriseScript = 'addr1w8phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcyjy7wx' as Cardano.PaymentAddress;
export const rewardKey = 'stake1uyehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gh6ffgw' as Cardano.PaymentAddress;
export const rewardScript = 'stake178phkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcccycj5' as Cardano.PaymentAddress;
export const testnetBasePaymentKeyStakeKey =
  'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3n0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgs68faae' as Cardano.PaymentAddress;
export const testnetBasePaymentScriptStakeKey =
  'addr_test1zrphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gten0d3vllmyqwsx5wktcd8cc3sq835lu7drv2xwl2wywfgsxj90mg' as Cardano.PaymentAddress;
export const testnetBasePaymentKeyStakeScript =
  'addr_test1yz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerkr0vd4msrxnuwnccdxlhdjar77j6lg0wypcc9uar5d2shsf5r8qx' as Cardano.PaymentAddress;
export const testnetBasePaymentScriptStakeScript =
  'addr_test1xrphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gt7r0vd4msrxnuwnccdxlhdjar77j6lg0wypcc9uar5d2shs4p04xh' as Cardano.PaymentAddress;
export const testnetPointerKey =
  'addr_test1gz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer5pnz75xxcrdw5vky' as Cardano.PaymentAddress;
export const testnetPointerScript =
  'addr_test12rphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtupnz75xxcryqrvmw' as Cardano.PaymentAddress;
export const testnetEnterpriseKey =
  'addr_test1vz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzerspjrlsz' as Cardano.PaymentAddress;
export const testnetEnterpriseScript =
  'addr_test1wrphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcl6szpr' as Cardano.PaymentAddress;
export const testnetRewardKey =
  'stake_test1uqehkck0lajq8gr28t9uxnuvgcqrc6070x3k9r8048z8y5gssrtvn' as Cardano.PaymentAddress;
export const testnetRewardScript =
  'stake_test17rphkx6acpnf78fuvxn0mkew3l0fd058hzquvz7w36x4gtcljw6kf' as Cardano.PaymentAddress;
export const byronMainnetYoroi =
  'Ae2tdPwUPEZFRbyhz3cpfC2CumGzNkFBN2L42rcUc2yjQpEkxDbkPodpMAi' as Cardano.PaymentAddress;
export const byronTestnetDaedalus =
  '37btjrVyb4KEB2STADSsj3MYSAdj52X5FrFWpw2r7Wmj2GDzXjFRsHWuZqrw7zSkwopv8Ci3VWeg6bisU9dgJxW5hb2MZYeduNKbQJrqz3zVBsu9nT' as Cardano.PaymentAddress;
