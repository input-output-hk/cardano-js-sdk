import { AccountKeyDerivationPath, KeyAgent, TransactionSigner, TransactionSignerResult } from '../types';
import { Cardano } from '@cardano-sdk/core';
import { ProofGenerationError } from '../errors';

const EXPECTED_SIG_NUM = 1;

/** Generates a Ed25519Signature of a transaction using a key agent. */
export class KeyAgentTransactionSigner implements TransactionSigner {
  #keyAgent: KeyAgent;
  #account: AccountKeyDerivationPath;

  /**
   * Initializes a new instance of the KeyAgentTransactionSigner class.
   *
   * @param keyAgent The key agent that will produce the signature.
   * @param account The account derivation path of the key to be used to generate the signature.
   * @class
   */
  constructor(keyAgent: KeyAgent, account: AccountKeyDerivationPath) {
    this.#keyAgent = keyAgent;
    this.#account = account;
  }

  /**
   * Sings a transaction.
   *
   * @param tx The transaction to be signed.
   * @returns A Ed25519 transaction signature.
   */
  async sign(tx: Cardano.TxBodyWithHash): Promise<TransactionSignerResult> {
    const signatures: Cardano.Signatures = await this.#keyAgent.signTransaction(
      tx,
      {
        knownAddresses: [],
        txInKeyPathMap: {}
      },
      {
        additionalKeyPaths: [this.#account]
      }
    );

    if (signatures.size !== EXPECTED_SIG_NUM)
      throw new ProofGenerationError(
        `Invalid number of signatures. Expected ${EXPECTED_SIG_NUM} and got ${signatures.size}`
      );

    const [pubKey] = signatures.keys();
    const [signature] = signatures.values();

    return { pubKey, signature };
  }
}
