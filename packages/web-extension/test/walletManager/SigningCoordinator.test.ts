import { Cardano, Serialization } from '@cardano-sdk/core';
import { Cip30DataSignature } from '@cardano-sdk/dapp-connector';
import {
  CommunicationType,
  InMemoryKeyAgent,
  KeyPurpose,
  SignDataContext,
  SignTransactionContext,
  cip8,
  errors
} from '@cardano-sdk/key-management';
import { Ed25519PublicKeyHex, Ed25519SignatureHex, Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import {
  InMemoryWallet,
  KeyAgentFactory,
  RequestContext,
  SigningCoordinator,
  WalletType,
  WrongTargetError
} from '../../src';
import { createAccount } from './util';
import { dummyLogger } from 'ts-log';
import { firstValueFrom } from 'rxjs';

describe('SigningCoordinator', () => {
  let signingCoordinator: SigningCoordinator<{}, {}>;
  let keyAgentFactory: jest.Mocked<KeyAgentFactory>;
  let keyAgent: jest.Mocked<InMemoryKeyAgent>;
  const wallet: InMemoryWallet<{}, {}> = {
    accounts: [createAccount(0, 0), createAccount(0, 0, KeyPurpose.MULTI_SIG)],
    encryptedSecrets: {
      keyMaterial: HexBlob('abc'),
      rootPrivateKeyBytes: HexBlob('123')
    },
    metadata: {},
    type: WalletType.InMemory,
    walletId: Hash28ByteBase16('ad63f855e831d937457afc52a21a7f351137e4a9fff26c217817335a')
  };
  const requestContext: RequestContext<{}, {}> = {
    accountIndex: 0,
    chainId: Cardano.ChainIds.Preprod,
    purpose: KeyPurpose.STANDARD,
    wallet
  };
  let passphrase: Uint8Array;
  const signatures: Cardano.Signatures = new Map([['keyhash' as Ed25519PublicKeyHex, 'sig' as Ed25519SignatureHex]]);

  beforeEach(() => {
    passphrase = new Uint8Array([1, 2, 3]);
    keyAgentFactory = {
      InMemory: jest.fn(),
      Ledger: jest.fn(),
      Trezor: jest.fn()
    };
    signingCoordinator = new SigningCoordinator(
      {
        hwOptions: {
          communicationType: CommunicationType.Node,
          manifest: {
            appUrl: 'https://test.app',
            email: 'test@test.app'
          }
        }
      },
      { keyAgentFactory, logger: dummyLogger }
    );
  });

  beforeEach(() => {
    keyAgent = {
      signBlob: jest.fn(),
      signCip8Data: jest.fn(),
      signTransaction: jest.fn()
    } as unknown as jest.Mocked<InMemoryKeyAgent>;
    keyAgentFactory.InMemory.mockResolvedValue(keyAgent);
  });

  describe('signTransaction', () => {
    const tx = Serialization.TxCBOR(
      // eslint-disable-next-line max-len
      '84a60081825820260aed6e7a24044b1254a87a509468a649f522a4e54e830ac10f27ea7b5ec61f01018383581d70b429738bd6cc58b5c7932d001aa2bd05cfea47020a556c8c753d44361a004c4b40582007845f8f3841996e3d8157954e2f5e2fb90465f27112fc5fe9056d916fae245b82583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba1a0463676982583900b1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339ba821a00177a6ea2581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff198a5447742544319271044774554481a0031f9194577444f47451a0056898d4577555344431a000fc589467753484942411a000103c2581c659ab0b5658687c2e74cd10dba8244015b713bf503b90557769d77a7a14a57696e675269646572731a02269552021a0002e665031a01353f84081a013531740b58204107eada931c72a600a6e3305bd22c7aeb9ada7c3f6823b155f4db85de36a69aa20081825820e686ade5bc97372f271fd2abc06cfd96c24b3d9170f9459de1d8e3dd8fd385575840653324a9dddad004f05a8ac99fa2d1811af5f00543591407fb5206cfe9ac91bb1412404323fa517e0e189684cd3592e7f74862e3f16afbc262519abec958180c0481d8799fd8799fd8799fd8799f581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c68ffd8799fd8799fd8799f581c042f1946335c498d2e7556c5c647c4649c6a69d2b645cd1428a339baffffffff581cb1814238b0d287a8a46ce7348c6ad79ab8995b0e6d46010e2d9e1c681b000001863784a12ed8799fd8799f4040ffd8799f581c648823ffdad1610b4162f4dbc87bd47f6f9cf45d772ddef661eff1984577444f4745ffffffd8799fd87980190c8efffff5f6'
    );
    const signContext: SignTransactionContext = { knownAddresses: [], txInKeyPathMap: {} };

    it('rejects given invalid tx cbor', async () => {
      await expect(
        signingCoordinator.signTransaction({ signContext, tx: 'abc' as Serialization.TxCBOR }, requestContext)
      ).rejects.toThrowError();
    });

    it('rejects with AuthenticationError when there is no subscriber', async () => {
      await expect(signingCoordinator.signTransaction({ signContext, tx }, requestContext)).rejects.toThrowError(
        WrongTargetError
      );
    });

    it('rejects with ProofGenerationError when account is not found', async () => {
      keyAgent.signTransaction.mockResolvedValueOnce(signatures);
      // subscribe to witness requests
      void firstValueFrom(signingCoordinator.transactionWitnessRequest$);
      await expect(
        signingCoordinator.signTransaction({ signContext, tx }, { ...requestContext, accountIndex: 999_999 })
      ).rejects.toThrowError(errors.ProofGenerationError);
    });

    it('signs with key agent when subscriber calls sign()', async () => {
      keyAgent.signTransaction.mockResolvedValueOnce(signatures);
      const reqEmitted = firstValueFrom(signingCoordinator.transactionWitnessRequest$);
      const signed = signingCoordinator.signTransaction({ signContext, tx }, requestContext);
      const req = await reqEmitted;
      await expect(req.sign(passphrase)).resolves.toEqual(signatures);
      await expect(signed).resolves.toEqual(signatures);
      expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
    });

    it('creates a key agent with requested purpose account', async () => {
      keyAgent.signTransaction.mockResolvedValueOnce(signatures);
      const reqEmitted = firstValueFrom(signingCoordinator.transactionWitnessRequest$);
      const signed = signingCoordinator.signTransaction(
        { signContext, tx },
        { ...requestContext, purpose: KeyPurpose.MULTI_SIG }
      );
      const req = await reqEmitted;
      await req.sign(passphrase);
      await signed;
      expect(keyAgentFactory.InMemory).toBeCalledWith(expect.objectContaining({ purpose: KeyPurpose.MULTI_SIG }));
    });

    it('rejects with AuthenticationError when subscriber calls reject()', async () => {
      const reqEmitted = firstValueFrom(signingCoordinator.transactionWitnessRequest$);
      const signed = signingCoordinator.signTransaction({ signContext, tx }, requestContext);
      const req = await reqEmitted;
      await req.reject("Don't want to");
      await expect(signed).rejects.toThrowError(errors.AuthenticationError);
    });

    it('rejects when key agent rejects', async () => {
      const error = new Error('invalid passphrase');
      keyAgent.signTransaction.mockRejectedValueOnce(error);
      const reqEmitted = firstValueFrom(signingCoordinator.transactionWitnessRequest$);
      const signed = signingCoordinator.signTransaction({ signContext, tx }, requestContext);
      const req = await reqEmitted;
      await expect(req.sign(passphrase)).rejects.toThrow(error);
      await expect(signed).rejects.toThrow(error);
      expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
    });

    describe('willRetryOnFailure=true', () => {
      it('does not resolve to original caller until successful signing', async () => {
        const error = new Error('invalid passphrase, please retry');
        keyAgent.signTransaction.mockRejectedValueOnce(error).mockResolvedValueOnce(signatures);
        const reqEmitted = firstValueFrom(signingCoordinator.transactionWitnessRequest$);
        const signed = signingCoordinator.signTransaction({ signContext, tx }, requestContext);
        const req = await reqEmitted;
        await expect(req.sign(passphrase, { willRetryOnFailure: true })).rejects.toThrow(error);
        await expect(req.sign(passphrase, { willRetryOnFailure: true })).resolves.toEqual(signatures);
        await expect(signed).resolves.toEqual(signatures);
        expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
      });

      it('does not reject to original caller until explicit rejection', async () => {
        const error = new Error('invalid passphrase, call reject if dont want to sign again');
        keyAgent.signTransaction.mockRejectedValueOnce(error).mockResolvedValueOnce(signatures);
        const reqEmitted = firstValueFrom(signingCoordinator.transactionWitnessRequest$);
        const signed = signingCoordinator.signTransaction({ signContext, tx }, requestContext);
        const req = await reqEmitted;
        await expect(req.sign(passphrase, { willRetryOnFailure: true })).rejects.toThrow(error);
        await req.reject('forgot password');
        await expect(signed).rejects.toThrowError(errors.AuthenticationError);
        expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
      });
    });
  });

  describe('signData', () => {
    const blob = HexBlob('abc123');
    const signResult: Cip30DataSignature = {
      key: 'abc' as cip8.CoseKeyCborHex,
      signature: '123' as cip8.CoseSign1CborHex
    };
    const signContext: SignDataContext = {
      knownAddresses: [],
      payload: blob,
      signWith: 'stubAddress' as Cardano.PaymentAddress
    };
    it('rejects with AuthenticationError when there is no subscriber', async () => {
      keyAgent.signCip8Data.mockResolvedValueOnce(signResult);
      await expect(signingCoordinator.signData(signContext, requestContext)).rejects.toThrowError(WrongTargetError);
    });

    it('rejects with ProofGenerationError when account is not found', async () => {
      keyAgent.signCip8Data.mockResolvedValueOnce(signResult);
      // subscribe to witness requests
      void firstValueFrom(signingCoordinator.signDataRequest$);

      await expect(
        signingCoordinator.signData(signContext, { ...requestContext, accountIndex: 999_999 })
      ).rejects.toThrowError(errors.ProofGenerationError);
    });

    it('signs with key agent when subscriber calls sign()', async () => {
      keyAgent.signCip8Data.mockResolvedValueOnce(signResult);
      const reqEmitted = firstValueFrom(signingCoordinator.signDataRequest$);
      const context = {
        knownAddresses: [],
        payload: blob,
        sender: { url: 'www.example.com' },
        signWith: 'stubAddress' as Cardano.PaymentAddress
      };
      const signed = signingCoordinator.signData(context, requestContext);
      const req = await reqEmitted;

      expect(req.signContext).toEqual(context);
      await expect(req.sign(passphrase)).resolves.toEqual(signResult);
      await expect(signed).resolves.toEqual(signResult);
      expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
    });

    it('rejects with AuthenticationError when subscriber calls reject()', async () => {
      const reqEmitted = firstValueFrom(signingCoordinator.signDataRequest$);
      const signed = signingCoordinator.signData(signContext, requestContext);
      const req = await reqEmitted;
      await req.reject("Don't want to");
      await expect(signed).rejects.toThrowError(errors.AuthenticationError);
    });

    it('rejects when key agent rejects', async () => {
      const error = new errors.AuthenticationError('invalid passphrase');
      keyAgent.signCip8Data.mockRejectedValueOnce(error);
      const reqEmitted = firstValueFrom(signingCoordinator.signDataRequest$);
      const signed = signingCoordinator.signData(signContext, requestContext);
      const req = await reqEmitted;
      await expect(req.sign(passphrase)).rejects.toThrow(error);
      await expect(signed).rejects.toThrow(error);
      expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
    });

    describe('willRetryOnFailure=true', () => {
      it('does not resolve to original caller until successful signing', async () => {
        const error = new Error('invalid passphrase, please retry');
        keyAgent.signCip8Data.mockRejectedValueOnce(error).mockResolvedValueOnce(signResult);
        const reqEmitted = firstValueFrom(signingCoordinator.signDataRequest$);
        const signed = signingCoordinator.signData(signContext, requestContext);
        const req = await reqEmitted;
        await expect(req.sign(passphrase, { willRetryOnFailure: true })).rejects.toThrow(error);
        await expect(req.sign(passphrase, { willRetryOnFailure: true })).resolves.toEqual(signResult);
        await expect(signed).resolves.toEqual(signResult);
        expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
      });

      it('does not reject to original caller until explicit rejection', async () => {
        const error = new Error('invalid passphrase, call reject if dont want to sign again');
        keyAgent.signCip8Data.mockRejectedValueOnce(error);
        const reqEmitted = firstValueFrom(signingCoordinator.signDataRequest$);
        const signed = signingCoordinator.signData(signContext, requestContext);
        const req = await reqEmitted;
        await expect(req.sign(passphrase, { willRetryOnFailure: true })).rejects.toThrow(error);
        await req.reject('forgot password');
        await expect(signed).rejects.toThrowError(errors.AuthenticationError);
        expect(passphrase).toEqual(new Uint8Array([0, 0, 0]));
      });
    });
  });
});
