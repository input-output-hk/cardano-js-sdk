import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet, createSharedWallet } from '../../../src';
import { Cardano } from '@cardano-sdk/core';
import { CommunicationType, KeyPurpose, KeyRole, util } from '@cardano-sdk/key-management';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { LedgerKeyAgent } from '@cardano-sdk/hardware-ledger';
import { dummyLogger as logger } from 'ts-log';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';

describe('LedgerSharedWalletKeyAgent', () => {
  let ledgerKeyAgent: LedgerKeyAgent;
  let wallet: BaseWallet;

  beforeAll(async () => {
    ledgerKeyAgent = await LedgerKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        communicationType: CommunicationType.Node,
        purpose: KeyPurpose.MULTI_SIG
      },
      { bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(), logger }
    );
  });

  afterAll(async () => {
    await ledgerKeyAgent.deviceConnection?.transport.close();
  });

  describe('signTransaction', () => {
    let txInternals: InitializeTxResult;

    beforeAll(async () => {
      const walletPubKey = await ledgerKeyAgent.derivePublicKey({ index: 0, role: KeyRole.External });
      const walletKeyHash = ledgerKeyAgent.bip32Ed25519.getPubKeyHash(walletPubKey);

      const walletStakePubKey = await ledgerKeyAgent.derivePublicKey({ index: 0, role: KeyRole.Stake });
      const walletStakeKeyHash = ledgerKeyAgent.bip32Ed25519.getPubKeyHash(walletStakePubKey);

      const paymentScript: Cardano.NativeScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAnyOf,
        scripts: [
          {
            __type: Cardano.ScriptType.Native,
            keyHash: walletKeyHash,
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
            keyHash: walletStakeKeyHash,
            kind: Cardano.NativeScriptKind.RequireSignature
          },
          {
            __type: Cardano.ScriptType.Native,
            keyHash: Crypto.Ed25519KeyHashHex('b275b08c999097247f7c17e77007c7010cd19f20cc086ad99d398539'),
            kind: Cardano.NativeScriptKind.RequireSignature
          }
        ]
      };

      const outputs: Cardano.TxOut[] = [
        {
          address: Cardano.PaymentAddress(
            'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
          ),
          scriptReference: paymentScript,
          value: { coins: 11_111_111n }
        }
      ];
      const props: InitializeTxProps = {
        outputs: new Set<Cardano.TxOut>(outputs)
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
          witnesser: util.createBip32Ed25519Witnesser(util.createAsyncKeyAgent(ledgerKeyAgent))
        }
      );
      txInternals = await wallet.initializeTx(props);
    });

    afterAll(() => wallet.shutdown());

    it('successfully signs a transaction', async () => {
      const tx = await wallet.finalizeTx({ tx: txInternals });
      expect(tx.witness.signatures.size).toBe(1);
    });
  });
});
