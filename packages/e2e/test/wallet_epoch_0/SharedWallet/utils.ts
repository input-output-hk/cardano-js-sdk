import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountKeyDerivationPath,
  KeyAgent,
  KeyPurpose,
  KeyRole,
  SignBlobResult,
  SignDataContext,
  SignTransactionContext,
  TransactionSigner,
  WitnessOptions,
  WitnessedTx,
  Witnesser,
  util
} from '@cardano-sdk/key-management';
import { Cardano, Serialization, TxCBOR } from '@cardano-sdk/core';
import { HexBlob } from '@cardano-sdk/util';
import { Logger } from 'ts-log';
import { bip32Ed25519Factory, createStandaloneKeyAgent, getSharedWallet } from '../../../src';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Crypto.Ed25519PublicKeyHex(Array.from({ length: 64 }).map(randomHexChar).join(''));

const DERIVATION_PATH = {
  index: 0,
  role: KeyRole.External
};

const getKeyAgent = async (
  mnemonics: string,
  genesisParameters: Cardano.CompactGenesis,
  bip32Ed25519: Crypto.Bip32Ed25519
) => {
  const keyAgent = await createStandaloneKeyAgent(
    mnemonics.split(' '),
    genesisParameters,
    bip32Ed25519,
    KeyPurpose.MULTI_SIG
  );

  const pubKey = await keyAgent.derivePublicKey(DERIVATION_PATH);

  return { keyAgent, pubKey };
};

const buildScript = async (expectedSigners: Array<Crypto.Ed25519PublicKeyHex>, bip32Ed25519: Crypto.Bip32Ed25519) => {
  const signers = [...expectedSigners];

  // Sorting guarantees that we will always get the same script if the same keys are used.
  signers.sort();

  // We are going to use RequireAllOf for this POC to keep it simple, but RequireNOf makes more sense.
  const script: Cardano.NativeScript = {
    __type: Cardano.ScriptType.Native,
    kind: Cardano.NativeScriptKind.RequireAllOf,
    scripts: []
  };

  for (const signer of signers) {
    script.scripts.push({
      __type: Cardano.ScriptType.Native,
      keyHash: await bip32Ed25519.getPubKeyHash(signer),
      kind: Cardano.NativeScriptKind.RequireSignature
    });
  }

  return script;
};

/**
 * Merges two arrays of items into a single array, avoiding duplication of items.
 *
 * @param arr1 The first array of items.
 * @param arr2 The second array of items.
 * @param serializeFn The function to serialize the items.
 * @returns The merged array of items.
 * @private
 */
const mergeArrays = <T>(arr1: T[], arr2: T[], serializeFn: (item: T) => HexBlob): T[] => {
  const serializedItems = new Set(arr1.map(serializeFn));
  const mergedArray = [...arr1];

  for (const item of arr2) {
    const serializedItem = serializeFn(item);
    if (!serializedItems.has(serializedItem)) {
      mergedArray.push(item);
      serializedItems.add(serializedItem);
    }
  }
  return mergedArray;
};

/**
 * Merges two witnesses into a single one avoiding duplication of witness data.
 *
 * @param lhs The left-hand side witness.
 * @param rhs The right-hand side witness.
 * @returns The merged witness.
 * @private
 */
// eslint-disable-next-line complexity
const mergeWitnesses = (lhs?: Cardano.Witness, rhs?: Cardano.Witness): Cardano.Witness => {
  if (!rhs) {
    if (!lhs) return { signatures: new Map() } as unknown as Cardano.Witness;
    return lhs as unknown as Cardano.Witness;
  }
  const mergedSignatures = new Map([...(lhs?.signatures ?? []), ...(rhs.signatures ?? [])]);

  // Merge arrays of complex objects
  const mergedRedeemers = mergeArrays(lhs?.redeemers || [], rhs.redeemers || [], (elem) =>
    Serialization.Redeemer.fromCore(elem).toCbor()
  );

  const mergedScripts = mergeArrays(lhs?.scripts || [], rhs.scripts || [], (elem) =>
    Serialization.Script.fromCore(elem).toCbor()
  );

  const mergedBootstrap = mergeArrays(lhs?.bootstrap || [], rhs.bootstrap || [], (elem) =>
    Serialization.BootstrapWitness.fromCore(elem).toCbor()
  );

  const mergedDatums = mergeArrays(lhs?.datums || [], rhs.datums || [], (elem) =>
    Serialization.PlutusData.fromCore(elem).toCbor()
  );

  return {
    bootstrap: mergedBootstrap,
    datums: mergedDatums,
    redeemers: mergedRedeemers,
    scripts: mergedScripts,
    signatures: mergedSignatures
  };
};

const getTxWithStubWitness = async (
  body: Cardano.TxBody,
  paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
  stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
  extraSigners?: TransactionSigner[],
  witness?: Cardano.Witness
): Promise<Cardano.Witness> => {
  const mockSignature = Crypto.Ed25519SignatureHex(
    // eslint-disable-next-line max-len
    'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
  );

  // Depending on the script, we need to provide a different number of signatures, however we will always compute the
  // transaction witness size with the maximum number of signatures possible since we don't know how many participants will want to sing
  // the transaction.
  const withdrawalSignatures = body.withdrawals && body.withdrawals.length > 0 ? stakingScript.scripts.length : 0;

  const paymentSignatures = paymentScript.scripts.length;
  const totalSignature = withdrawalSignatures + paymentSignatures + (extraSigners?.length || 0);
  const signatureMap = new Map();

  for (let i = 0; i < totalSignature; ++i) signatureMap.set(randomPublicKey(), mockSignature);

  const stubWitness = mergeWitnesses({ scripts: [], signatures: new Map() }, witness as Cardano.Witness);

  stubWitness.signatures = new Map([
    ...(stubWitness.signatures ? stubWitness.signatures.entries() : []),
    ...signatureMap.entries()
  ]);
  stubWitness.scripts = [...(stubWitness.scripts ?? []), paymentScript, stakingScript];

  return stubWitness;
};

const createWitnessData = async (
  keyAgent: KeyAgent,
  paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
  stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
  tx: Serialization.Transaction,
  context: SignTransactionContext,
  options?: WitnessOptions
  // eslint-disable-next-line max-params
): Promise<Cardano.Witness> => ({
  scripts: [paymentScript, stakingScript],
  signatures: await keyAgent.signTransaction(
    {
      body: tx.body().toCore(),
      hash: tx.getId()
    },
    context,
    { ...options, additionalKeyPaths: [...(options?.additionalKeyPaths ?? []), DERIVATION_PATH] } // The key agent wont be able to find the right key if we don't provide the derivation path.
  )
});

// Naive witnesser that always signs with the same key, this will work for this test since both
// stake and payment scripts use the same key.
export class SharedWalletWitnesser implements Witnesser {
  #keyAgent: KeyAgent;
  #paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;
  #stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript;

  constructor(
    keyAgent: KeyAgent,
    paymentScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript,
    stakingScript: Cardano.RequireAllOfScript | Cardano.RequireAnyOfScript | Cardano.RequireAtLeastScript
  ) {
    // At creation we should also check that our keyagent controls at least one key in each script, otherwise throw.
    this.#keyAgent = keyAgent;
    this.#paymentScript = paymentScript;
    this.#stakingScript = stakingScript;
  }

  async signBlob(
    _derivationPath: AccountKeyDerivationPath,
    _blob: HexBlob,
    _context: SignDataContext
  ): Promise<SignBlobResult> {
    throw new Error('Method not implemented.');
  }

  async witness(
    tx: Serialization.Transaction,
    context: SignTransactionContext,
    options?: WitnessOptions
  ): Promise<WitnessedTx> {
    let witness;
    const coreTx = tx.toCore();
    const hash = tx.getId();

    if (options?.stubSign !== undefined && options.stubSign) {
      witness = await getTxWithStubWitness(
        coreTx.body,
        this.#paymentScript,
        this.#stakingScript,
        options.extraSigners,
        coreTx.witness
      );
    } else {
      witness = await createWitnessData(
        this.#keyAgent,
        this.#paymentScript,
        this.#stakingScript,
        new Serialization.Transaction(
          Serialization.TransactionBody.fromCore(coreTx.body),
          new Serialization.TransactionWitnessSet()
        ),
        context,
        options
      );

      const extraSignatures: Cardano.Signatures = new Map();
      if (options?.extraSigners) {
        for (const extraSigner of options?.extraSigners) {
          const extraSignature = await extraSigner.sign({
            body: coreTx.body,
            hash
          });
          extraSignatures.set(extraSignature.pubKey, extraSignature.signature);
        }
      }

      witness.signatures = new Map([
        ...(witness.signatures ? witness.signatures.entries() : []),
        ...extraSignatures.entries()
      ]);
    }

    const transaction = {
      auxiliaryData: coreTx.auxiliaryData,
      body: coreTx.body,
      id: hash,
      isValid: tx.isValid(),
      witness: mergeWitnesses(coreTx.witness, witness)
    };

    return {
      cbor: TxCBOR.serialize(transaction),
      context: {
        handleResolutions: context.handleResolutions ?? []
      },
      tx: transaction
    };
  }
}

/* eslint-disable @typescript-eslint/no-explicit-any */
export const buildSharedWallets = async (env: any, genesisParameters: Cardano.CompactGenesis, logger: Logger) => {
  const bip32Ed25519 = await bip32Ed25519Factory.create(env.KEY_MANAGEMENT_PARAMS.bip32Ed25519, null, logger);
  const aliceMnemonics = util.generateMnemonicWords().join(' ');
  const bobMnemonics = util.generateMnemonicWords().join(' ');
  const charlotteMnemonics = util.generateMnemonicWords().join(' ');

  const alice = await getKeyAgent(aliceMnemonics, genesisParameters, bip32Ed25519);
  const bob = await getKeyAgent(bobMnemonics, genesisParameters, bip32Ed25519);
  const charlotte = await getKeyAgent(charlotteMnemonics, genesisParameters, bip32Ed25519);

  const multiSigParticipants = [alice.pubKey, bob.pubKey, charlotte.pubKey];

  const paymentScript = await buildScript(multiSigParticipants, bip32Ed25519);
  const stakingScript = await buildScript(multiSigParticipants, bip32Ed25519);

  const aliceMultiSigWallet = (
    await getSharedWallet({
      env,
      logger,
      name: 'Alice shared Wallet',
      paymentScript,
      polling: { interval: 50 },
      stakingScript,
      witnesser: new SharedWalletWitnesser(alice.keyAgent, paymentScript, stakingScript)
    })
  ).wallet;

  const bobMultiSigWallet = (
    await getSharedWallet({
      env,
      logger,
      name: 'Bob shared Wallet',
      paymentScript,
      polling: { interval: 50 },
      stakingScript,
      witnesser: new SharedWalletWitnesser(bob.keyAgent, paymentScript, stakingScript)
    })
  ).wallet;

  const charlotteMultiSigWallet = (
    await getSharedWallet({
      env,
      logger,
      name: 'Charlotte shared Wallet',
      paymentScript,
      polling: { interval: 50 },
      stakingScript,
      witnesser: new SharedWalletWitnesser(charlotte.keyAgent, paymentScript, stakingScript)
    })
  ).wallet;

  return { aliceMultiSigWallet, bobMultiSigWallet, charlotteMultiSigWallet };
};
