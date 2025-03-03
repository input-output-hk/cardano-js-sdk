import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet, createSharedWallet } from '../../../src';
import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyPurpose, KeyRole, TrezorConfig, util } from '@cardano-sdk/key-management';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { dummyLogger as logger } from 'ts-log';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';

describe('TrezorSharedWalletKeyAgent', () => {
  let wallet: BaseWallet;
  let trezorKeyAgent: TrezorKeyAgent;
  let paymentScript: Cardano.NativeScript;

  const trezorConfig: TrezorConfig = {
    communicationType: CommunicationType.Node,
    manifest: {
      appUrl: 'https://your.application.com',
      email: 'email@developer.com'
    },
    shouldHandlePassphrase: true
  };

  beforeAll(async () => {
    trezorKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.MULTI_SIG,
        trezorConfig
      },
      {
        bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(),
        logger
      }
    );

    const paymentKeyHash = trezorKeyAgent.bip32Ed25519.getPubKeyHash(
      await trezorKeyAgent.derivePublicKey({ index: 0, role: KeyRole.External })
    );
    const stakeKeyHash = trezorKeyAgent.bip32Ed25519.getPubKeyHash(
      await trezorKeyAgent.derivePublicKey({ index: 0, role: KeyRole.Stake })
    );

    paymentScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: paymentKeyHash,
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398539'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };

    const stakingScript: Cardano.NativeScript = {
      __type: Cardano.ScriptType.Native,
      kind: Cardano.NativeScriptKind.RequireAnyOf,
      scripts: [
        {
          __type: Cardano.ScriptType.Native,
          keyHash: stakeKeyHash,
          kind: Cardano.NativeScriptKind.RequireSignature
        },
        {
          __type: Cardano.ScriptType.Native,
          keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398539'),
          kind: Cardano.NativeScriptKind.RequireSignature
        }
      ]
    };

    wallet = createSharedWallet(
      { name: 'Shared HW Wallet' },
      {
        assetProvider: mocks.mockAssetProvider(),
        chainHistoryProvider: mocks.mockChainHistoryProvider(),
        logger,
        networkInfoProvider: mocks.mockNetworkInfoProvider(),
        paymentScript,
        rewardAccountInfoProvider: mocks.mockRewardAccountInfoProvider(),
        rewardsProvider: mocks.mockRewardsProvider(),
        stakingScript,
        txSubmitProvider: mocks.mockTxSubmitProvider(),
        utxoProvider: mocks.mockUtxoProvider(),
        witnesser: util.createBip32Ed25519Witnesser(util.createAsyncKeyAgent(trezorKeyAgent))
      }
    );
  });

  afterAll(() => wallet.shutdown());

  describe('Sign Transaction', () => {
    let props: InitializeTxProps;
    let txInternals: InitializeTxResult;
    const simpleOutput = {
      address: Cardano.PaymentAddress(
        'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
      ),
      value: { coins: 11_111_111n }
    };

    it('should sign simple multi-sig transaction', async () => {
      props = {
        outputs: new Set<Cardano.TxOut>([simpleOutput])
      };
      txInternals = await wallet.initializeTx(props);
      const witnessedTx = await wallet.finalizeTx({
        signingContext: { scripts: [paymentScript] },
        tx: txInternals
      });
      expect(witnessedTx.witness.signatures.size).toBe(1);
    });
  });
});
