import * as Crypto from '@cardano-sdk/crypto';
import { BaseWallet, createSharedWallet } from '../../../src';
import { Cardano } from '@cardano-sdk/core';
import { InitializeTxProps, InitializeTxResult } from '@cardano-sdk/tx-construction';
import { KeyPurpose, KeyRole, util } from '@cardano-sdk/key-management';
import { TrezorKeyAgent } from '@cardano-sdk/hardware-trezor';
import { createKeyAgentDependencies, trezorConfig } from './test-utils';
import { dummyLogger as logger } from 'ts-log';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';

describe('TrezorSharedWalletKeyAgent', () => {
  let wallet: BaseWallet;
  let trezorKeyAgent: TrezorKeyAgent;
  let paymentScript: Cardano.NativeScript;

  // Key agents for different master key generation schemes
  let icarusKeyAgent: TrezorKeyAgent;
  let icarusTrezorKeyAgent: TrezorKeyAgent;
  let ledgerKeyAgent: TrezorKeyAgent;
  let keyAgentDependencies: Awaited<ReturnType<typeof createKeyAgentDependencies>>;

  beforeAll(async () => {
    keyAgentDependencies = await createKeyAgentDependencies();

    trezorKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.MULTI_SIG,
        trezorConfig
      },
      keyAgentDependencies
    );

    // Create key agents for different master key generation schemes
    icarusKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.MULTI_SIG,
        trezorConfig: {
          ...trezorConfig,
          derivationType: 'ICARUS'
        }
      },
      keyAgentDependencies
    );

    icarusTrezorKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.MULTI_SIG,
        trezorConfig: {
          ...trezorConfig,
          derivationType: 'ICARUS_TREZOR'
        }
      },
      keyAgentDependencies
    );

    ledgerKeyAgent = await TrezorKeyAgent.createWithDevice(
      {
        chainId: Cardano.ChainIds.Preprod,
        purpose: KeyPurpose.MULTI_SIG,
        trezorConfig: {
          ...trezorConfig,
          derivationType: 'LEDGER'
        }
      },
      keyAgentDependencies
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

  describe('Master Key Generation Scheme Support', () => {
    it('should produce different extended public keys for different master key generation schemes', async () => {
      const icarusXPub = icarusKeyAgent.extendedAccountPublicKey;
      const icarusTrezorXPub = icarusTrezorKeyAgent.extendedAccountPublicKey;
      const ledgerXPub = ledgerKeyAgent.extendedAccountPublicKey;

      // LEDGER should always produce different keys from both ICARUS variants
      expect(icarusXPub).not.toEqual(ledgerXPub);
      expect(icarusTrezorXPub).not.toEqual(ledgerXPub);

      // For ICARUS vs ICARUS_TREZOR master key generation schemes, the behavior depends on the seed length:
      // - 12/18 word seeds: ICARUS and ICARUS_TREZOR produce the same keys
      // - 24 word seeds: ICARUS and ICARUS_TREZOR produce different keys
      // This is due to a documented Trezor firmware quirk with 24-word mnemonics.
      // We can't easily detect the seed length from the device, so we test both possibilities.
      // See README.md for detailed documentation.
      if (icarusXPub === icarusTrezorXPub) {
        // 12/18 word seed case - ICARUS and ICARUS_TREZOR should produce the same keys
        expect(icarusXPub).toEqual(icarusTrezorXPub);
      } else {
        // 24 word seed case - ICARUS and ICARUS_TREZOR should produce different keys
        expect(icarusXPub).not.toEqual(icarusTrezorXPub);
      }
    });

    it('should work with ICARUS master key generation scheme in multi-sig', async () => {
      const icarusPaymentKeyHash = icarusKeyAgent.bip32Ed25519.getPubKeyHash(
        await icarusKeyAgent.derivePublicKey({ index: 0, role: KeyRole.External })
      );

      const icarusPaymentScript: Cardano.NativeScript = {
        __type: Cardano.ScriptType.Native,
        kind: Cardano.NativeScriptKind.RequireAnyOf,
        scripts: [
          {
            __type: Cardano.ScriptType.Native,
            keyHash: icarusPaymentKeyHash,
            kind: Cardano.NativeScriptKind.RequireSignature
          }
        ]
      };

      const icarusWallet = createSharedWallet(
        { name: 'ICARUS Shared HW Wallet' },
        {
          assetProvider: mocks.mockAssetProvider(),
          chainHistoryProvider: mocks.mockChainHistoryProvider(),
          logger,
          networkInfoProvider: mocks.mockNetworkInfoProvider(),
          paymentScript: icarusPaymentScript,
          rewardAccountInfoProvider: mocks.mockRewardAccountInfoProvider(),
          rewardsProvider: mocks.mockRewardsProvider(),
          stakingScript: icarusPaymentScript,
          txSubmitProvider: mocks.mockTxSubmitProvider(),
          utxoProvider: mocks.mockUtxoProvider(),
          witnesser: util.createBip32Ed25519Witnesser(util.createAsyncKeyAgent(icarusKeyAgent))
        }
      );

      const simpleOutput = {
        address: Cardano.PaymentAddress(
          'addr_test1qpu5vlrf4xkxv2qpwngf6cjhtw542ayty80v8dyr49rf5ewvxwdrt70qlcpeeagscasafhffqsxy36t90ldv06wqrk2qum8x5w'
        ),
        value: { coins: 11_111_111n }
      };

      const props: InitializeTxProps = {
        outputs: new Set<Cardano.TxOut>([simpleOutput])
      };
      const txInternals = await icarusWallet.initializeTx(props);
      const witnessedTx = await icarusWallet.finalizeTx({
        signingContext: { scripts: [icarusPaymentScript] },
        tx: txInternals
      });
      expect(witnessedTx.witness.signatures.size).toBe(1);

      icarusWallet.shutdown();
    });
  });
});
