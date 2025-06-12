import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet, cip30 } from '@cardano-sdk/wallet';
import { Bip32Account, KeyRole, cip8 } from '@cardano-sdk/key-management';
import { COSEKey, COSESign1 } from '@emurgo/cardano-message-signing-nodejs';
import { Cardano, util } from '@cardano-sdk/core';
import { Cip30DataSignature, SenderContext } from '@cardano-sdk/dapp-connector';
import { HexBlob } from '@cardano-sdk/util';
import { NEVER, firstValueFrom, of } from 'rxjs';
import { buildDRepAddressFromDRepKey } from '../../../../wallet/test/util';
import { getEnv, getWallet, walletReady, walletVariables } from '../../../src';
import { logger } from '@cardano-sdk/util-dev';

const env = getEnv(walletVariables);

const decodeSignature = (dataSignature: Cip30DataSignature) => {
  const coseKey = COSEKey.from_bytes(Buffer.from(dataSignature.key, 'hex'));
  const coseSign1 = COSESign1.from_bytes(Buffer.from(dataSignature.signature, 'hex'));

  const publicKeyHeader = coseKey.header(cip8.CoseLabel.x)!;
  const publicKeyBytes = publicKeyHeader.as_bytes()!;
  const publicKeyHex = util.bytesToHex(publicKeyBytes);
  const signedData = coseSign1.signed_data();
  return { coseKey, coseSign1, publicKeyHex, signedData };
};

describe('PersonalWallet/cip30WalletApi', () => {
  let wallet: BaseWallet;
  let drepKeyHashHex: Crypto.Ed25519KeyHashHex;
  let drepPubKey: Crypto.Ed25519PublicKeyHex;
  let walletApi: ReturnType<typeof cip30.createWalletApi>;
  let bip32Account: Bip32Account;

  beforeEach(async () => {
    ({ wallet, bip32Account } = await getWallet({ env, logger, name: 'wallet' }));
    await walletReady(wallet, 10n);

    drepPubKey = (await wallet.governance.getPubDRepKey())!;
    drepKeyHashHex = (await Crypto.Ed25519PublicKey.fromHex(drepPubKey!).hash()).hex();

    walletApi = cip30.createWalletApi(
      of(wallet),
      {
        signData: () => Promise.resolve({ cancel$: NEVER })
      } as unknown as cip30.CallbackConfirmation,
      { logger: console }
    );
  });

  it('can signData with hex DRepID', async () => {
    const signature = await walletApi.signData(
      { sender: '' } as unknown as SenderContext,
      drepKeyHashHex,
      HexBlob('abc123')
    );

    expect(decodeSignature(signature).publicKeyHex).toEqual(drepPubKey);
  });

  it('can signData with bech32 type 6 addr DRepID', async () => {
    const drepAddr = (await buildDRepAddressFromDRepKey(drepPubKey))?.toAddress()?.toBech32();
    const signature = await walletApi.signData(
      { sender: '' } as unknown as SenderContext,
      drepAddr!,
      HexBlob('abc123')
    );

    expect(decodeSignature(signature).publicKeyHex).toEqual(drepPubKey);
  });

  it('can signData with bech32 base address', async () => {
    const [{ address, index }] = await firstValueFrom(wallet.addresses$);
    const paymentKeyHex = bip32Account.derivePublicKey({ index, role: KeyRole.External });

    const signature = await walletApi.signData({ sender: '' } as unknown as SenderContext, address, HexBlob('abc123'));

    expect(decodeSignature(signature).publicKeyHex).toEqual(paymentKeyHex);
  });

  it('can signData with hex-encoded base address', async () => {
    const [{ address, index }] = await firstValueFrom(wallet.addresses$);
    const addressHex = Cardano.Address.fromBech32(address).toBytes();
    const paymentKeyHex = bip32Account.derivePublicKey({ index, role: KeyRole.External });

    const signature = await walletApi.signData(
      { sender: '' } as unknown as SenderContext,
      addressHex,
      HexBlob('abc123')
    );

    expect(decodeSignature(signature).publicKeyHex).toEqual(paymentKeyHex);
  });

  it('can signData with bech32 base address', async () => {
    const [{ rewardAccount, index }] = await firstValueFrom(wallet.addresses$);
    const stakeKeyHex = bip32Account.derivePublicKey({ index, role: KeyRole.Stake });

    const signature = await walletApi.signData(
      { sender: '' } as unknown as SenderContext,
      rewardAccount,
      HexBlob('abc123')
    );

    expect(decodeSignature(signature).publicKeyHex).toEqual(stakeKeyHex);
  });

  it('can signData with hex-encoded reward account', async () => {
    const [{ rewardAccount, index }] = await firstValueFrom(wallet.addresses$);
    const rewardAccountHex = Cardano.Address.fromBech32(rewardAccount).toBytes();
    const stakeKeyHex = bip32Account.derivePublicKey({ index, role: KeyRole.Stake });

    const signature = await walletApi.signData(
      { sender: '' } as unknown as SenderContext,
      rewardAccountHex,
      HexBlob('abc123')
    );

    expect(decodeSignature(signature).publicKeyHex).toEqual(stakeKeyHex);
  });
});
