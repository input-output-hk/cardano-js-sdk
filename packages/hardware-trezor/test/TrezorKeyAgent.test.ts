import * as Trezor from '@trezor/connect';
import { CardanoKeyConst, util } from '@cardano-sdk/key-management';
import { TrezorKeyAgent } from '../src/index.js';
import { knownAddressKeyPath, knownAddressStakeKeyPath } from './testData.js';

describe('TrezorKeyAgent', () => {
  // Transformed / mapped data
  const txIn = {
    prev_hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f190000',
    prev_index: 0
  };

  const txInWithPath = {
    path: [util.harden(CardanoKeyConst.PURPOSE), util.harden(CardanoKeyConst.COIN_TYPE), util.harden(0), 1, 0],
    prev_hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f190000',
    prev_index: 0
  };

  const txOut = {
    address:
      'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp',
    amount: '10',
    format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
  };

  const txOutToOwnedAddress = {
    addressParameters: {
      addressType: Trezor.PROTO.CardanoAddressType.BASE,
      path: knownAddressKeyPath,
      stakingPath: knownAddressStakeKeyPath
    },
    amount: '10',
    format: Trezor.PROTO.CardanoTxOutputSerializationFormat.ARRAY_LEGACY
  };

  const stakeRegistrationCertificate = {
    scriptHash: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
    type: Trezor.PROTO.CardanoCertificateType.STAKE_REGISTRATION
  };

  const simpleTx: Omit<Trezor.CardanoSignTransaction, 'signingMode'> = {
    fee: '10',
    inputs: [txInWithPath],
    networkId: 0,
    outputs: [txOutToOwnedAddress],
    protocolMagic: 999
  };

  const validMultisigTx: Omit<Trezor.CardanoSignTransaction, 'signingMode'> = {
    // Contains ONLY script hash credentials
    certificates: [stakeRegistrationCertificate],

    fee: '10',

    // All third party inputs
    inputs: [txIn],

    networkId: 0,
    // All third party outputs
    outputs: [txOut],
    protocolMagic: 999
  };

  const poolRegistrationCertificate = {
    poolParameters: {
      cost: '1000',
      margin: {
        denominator: '5',
        numerator: '1'
      },
      metadata: {
        hash: '0f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5',
        url: 'https://example.com'
      },
      owners: [
        {
          stakingKeyPath: [
            util.harden(CardanoKeyConst.PURPOSE),
            util.harden(CardanoKeyConst.COIN_TYPE),
            util.harden(0),
            2,
            0
          ]
        }
      ],
      pledge: '10000',
      poolId: 'cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f',
      relays: [
        {
          ipv4Address: '127.0.0.1',
          port: 6000,
          type: 0
        },
        {
          hostName: 'example.com',
          port: 5000,
          type: 1
        },
        {
          hostName: 'example.com',
          type: 2
        }
      ],
      rewardAccount: 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr',
      vrfKeyHash: '8dd154228946bd12967c12bedb1cb6038b78f8b84a1760b1a788fa72a4af3db0'
    },
    type: Trezor.PROTO.CardanoCertificateType.STAKE_POOL_REGISTRATION
  };

  const validPlutusTx = {
    ...simpleTx,
    collateralInputs: [txInWithPath]
  };
  // END of Transformed / mapped data

  describe('matchSigningMode', () => {
    it('can detect ordinary transaction signing mode', async () => {
      const signingMode = TrezorKeyAgent.matchSigningMode(simpleTx);
      expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.ORDINARY_TRANSACTION);
    });

    it('can detect pool registrations signing mode', async () => {
      const signingMode = TrezorKeyAgent.matchSigningMode({
        ...simpleTx,
        certificates: [poolRegistrationCertificate]
      });
      expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.POOL_REGISTRATION_AS_OWNER);
    });

    it('can detect plutus transaction signing mode', async () => {
      const signingMode = TrezorKeyAgent.matchSigningMode(validPlutusTx);
      expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.PLUTUS_TRANSACTION);
    });

    it('can detect multisig transaction signing mode', async () => {
      const signingMode = TrezorKeyAgent.matchSigningMode(validMultisigTx);
      expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.MULTISIG_TRANSACTION);
    });

    describe('broader plutus signing mode usage', () => {
      it('matches plutus signing mode if multisig tx body contains collateral inputs', async () => {
        const signingMode = TrezorKeyAgent.matchSigningMode({
          ...validMultisigTx,
          collateralInputs: [txIn]
        });
        expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.PLUTUS_TRANSACTION);
      });

      it('matches plutus signing mode if multisig tx body contains collateral outputs', async () => {
        const signingMode = TrezorKeyAgent.matchSigningMode({
          ...validMultisigTx,
          collateralReturn: txOut
        });
        expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.PLUTUS_TRANSACTION);
      });

      it('matches plutus signing mode if multisig tx body contains total collateral', async () => {
        const signingMode = TrezorKeyAgent.matchSigningMode({
          ...validMultisigTx,
          totalCollateral: '10'
        });
        expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.PLUTUS_TRANSACTION);
      });

      it('matches plutus signing mode if multisig tx body contains reference input', async () => {
        const signingMode = TrezorKeyAgent.matchSigningMode({
          ...validMultisigTx,
          referenceInputs: [txIn]
        });
        expect(signingMode).toEqual(Trezor.PROTO.CardanoTxSigningMode.PLUTUS_TRANSACTION);
      });
    });
  });
});
