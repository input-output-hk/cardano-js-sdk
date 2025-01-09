import * as Crypto from '@cardano-sdk/crypto';
import {
  AccountKeyDerivationPath,
  AddressType,
  GroupedAddress,
  InMemoryKeyAgent,
  KeyRole
} from '@cardano-sdk/key-management';
import {
  Cardano,
  ChainHistoryProvider,
  Reward,
  RewardsProvider,
  Serialization,
  TxSubmitProvider,
  UtxoProvider,
  coalesceValueQuantities,
  nativeScriptPolicyId,
  util
} from '@cardano-sdk/core';
import { GreedyTxEvaluator, defaultSelectionConstraints } from '@cardano-sdk/tx-construction';
import { InputSelector, StaticChangeAddressResolver, roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import { MultiSigTx } from './MultiSigTx';
import { Observable, firstValueFrom, interval, map, switchMap } from 'rxjs';
import { WalletNetworkInfoProvider } from '@cardano-sdk/wallet';

const randomHexChar = () => Math.floor(Math.random() * 16).toString(16);
const randomPublicKey = () => Crypto.Ed25519PublicKeyHex(Array.from({ length: 64 }).map(randomHexChar).join(''));

// eslint-disable-next-line max-len
const DUMMY_HEX_BYTES =
  'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

const DERIVATION_PATH: AccountKeyDerivationPath = {
  index: 0,
  role: KeyRole.External
};

export class MultiSigWalletProps {
  expectedSigners: Array<Crypto.Ed25519PublicKeyHex> = [];
  inMemoryKeyAgent: InMemoryKeyAgent;
  utxoProvider: UtxoProvider;
  chainHistoryProvider: ChainHistoryProvider;
  rewardsProvider: RewardsProvider;
  txSubmitProvider: TxSubmitProvider;
  networkInfoProvider: WalletNetworkInfoProvider;
  networkId: Cardano.NetworkId;
  pollingInterval: number;
}

/** Represents a multi-signature wallet for Cardano blockchain. */
export class MultiSigWallet {
  #expectedSigners: Array<Crypto.Ed25519PublicKeyHex> = [];
  #inMemoryKeyAgent: InMemoryKeyAgent;
  #multisigScript: Cardano.NativeScript;
  #inputSelector: InputSelector;
  #address: GroupedAddress;
  #utxoProvider: UtxoProvider;
  #chainHistoryProvider: ChainHistoryProvider;
  #rewardsProvider: RewardsProvider;
  #txSubmitProvider: TxSubmitProvider;
  #networkInfoProvider: WalletNetworkInfoProvider;
  #pollingInterval: number;

  /** Creates a new MultiSigWallet instance with the specified signers and network configuration. */
  static async createMultiSigWallet(props: MultiSigWalletProps) {
    const script = await MultiSigWallet.#buildScript(props.expectedSigners, props.inMemoryKeyAgent);
    const address = await MultiSigWallet.#getAddress(script, props.networkId);

    const inputSelector = roundRobinRandomImprove({
      changeAddressResolver: new StaticChangeAddressResolver(() => Promise.resolve([address]))
    });

    return new MultiSigWallet(props, script, address, inputSelector);
  }

  /** Constructs a new MultiSigWallet. */
  constructor(
    props: MultiSigWalletProps,
    script: Cardano.NativeScript,
    address: GroupedAddress,
    inputSelector: InputSelector
  ) {
    this.#multisigScript = script;
    this.#address = address;
    this.#inputSelector = inputSelector;
    this.#expectedSigners = props.expectedSigners;
    this.#inMemoryKeyAgent = props.inMemoryKeyAgent;
    this.#utxoProvider = props.utxoProvider;
    this.#chainHistoryProvider = props.chainHistoryProvider;
    this.#rewardsProvider = props.rewardsProvider;
    this.#txSubmitProvider = props.txSubmitProvider;
    this.#networkInfoProvider = props.networkInfoProvider;
    this.#pollingInterval = props.pollingInterval;
  }

  /**
   * Retrieves the list of signers' public keys.
   *
   * @returns {Array<Crypto.Ed25519PublicKeyHex>} An array of signers' public keys.
   */
  getSigners(): Array<Crypto.Ed25519PublicKeyHex> {
    return this.#expectedSigners;
  }

  /**
   * Retrieves the payment address of the wallet.
   *
   * @returns {Cardano.PaymentAddress} The payment address.
   */
  getPaymentAddress(): Cardano.PaymentAddress {
    return this.#address.address;
  }

  /**
   * Retrieves the reward account associated with the wallet.
   *
   * @returns {Cardano.RewardAccount} The reward account.
   */
  getRewardAccount(): Cardano.RewardAccount {
    return this.#address.rewardAccount;
  }

  /**
   * Delegates the stake to a specified pool.
   *
   * @param {Cardano.PoolId} pool - The pool ID to delegate to.
   * @returns {Promise<MultiSigTx>} A multi-signature transaction object for the delegation.
   */
  async delegate(pool: Cardano.PoolId): Promise<MultiSigTx> {
    const certificates: Cardano.Certificate[] = [];

    certificates.push(
      {
        __typename: Cardano.CertificateType.StakeRegistration,
        stakeCredential: {
          hash: Cardano.RewardAccount.toHash(this.getRewardAccount()),
          type: Cardano.CredentialType.ScriptHash
        }
      },
      {
        __typename: Cardano.CertificateType.StakeDelegation,
        poolId: pool,
        stakeCredential: {
          hash: Cardano.RewardAccount.toHash(this.getRewardAccount()),
          type: Cardano.CredentialType.ScriptHash
        }
      }
    );

    const { body, id } = await this.#createTransaction(
      // Add dummy output. This is not needed, but probably ok for POC.
      new Set<Cardano.TxOut>([
        {
          address: this.getPaymentAddress(),
          value: { coins: 1_000_000n }
        }
      ]),
      certificates
    );

    return new MultiSigTx(
      {
        body,
        id,
        witness: {
          scripts: [this.#multisigScript],
          signatures: new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>()
        }
      },
      this.#expectedSigners
    );
  }

  /**
   * Transfers funds to a specified address.
   *
   * @param {Cardano.PaymentAddress} address - The address to transfer funds to.
   * @param {Cardano.Value} value - The amount to be transferred.
   * @returns {Promise<MultiSigTx>} A multi-signature transaction object for the transfer.
   */
  async transferFunds(address: Cardano.PaymentAddress, value: Cardano.Value): Promise<MultiSigTx> {
    const { body, id } = await this.#createTransaction(
      new Set<Cardano.TxOut>([
        {
          address,
          value
        }
      ])
    );

    return new MultiSigTx(
      {
        body,
        id,
        witness: {
          scripts: [this.#multisigScript],
          signatures: new Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>()
        }
      },
      this.#expectedSigners
    );
  }

  /**
   * Signs a multi-signature transaction.
   *
   * @param {MultiSigTx} multiSigTx - The multi-signature transaction to sign.
   * @returns {Promise<MultiSigTx>} The signed multi-signature transaction.
   */
  async sign(multiSigTx: MultiSigTx): Promise<MultiSigTx> {
    const currentSignatures = multiSigTx.getTransaction().witness.signatures;
    const newSignatures = await this.#inMemoryKeyAgent.signTransaction(
      Serialization.TransactionBody.fromCore(multiSigTx.getTransaction().body),
      { knownAddresses: [this.#address], txInKeyPathMap: {} },
      { additionalKeyPaths: [DERIVATION_PATH] }
    );

    for (const signature of newSignatures.entries()) {
      currentSignatures.set(signature[0], signature[1]);
    }

    multiSigTx.getTransaction().witness.signatures = currentSignatures;

    return multiSigTx;
  }

  /**
   * Submits a signed multi-signature transaction to the network.
   *
   * @param {MultiSigTx} multiSigTx - The signed multi-signature transaction to submit.
   * @returns {Promise<Cardano.TransactionId>} The transaction ID of the submitted transaction.
   */
  async submit(multiSigTx: MultiSigTx): Promise<Cardano.TransactionId> {
    const tx = Serialization.Transaction.fromCore(multiSigTx.getTransaction());

    await this.#txSubmitProvider.submitTx({
      signedTransaction: tx.toCbor()
    });

    return tx.getId();
  }

  /**
   * Retrieves the set of unspent transaction outputs (UTXOs) associated with the wallet.
   *
   * @returns {Observable<Cardano.Utxo[]>} A hot observable with the list of  current UTXOs.
   */
  getUtxoSet(): Observable<Cardano.Utxo[]> {
    return interval(this.#pollingInterval).pipe(
      switchMap(
        () =>
          new Observable<Cardano.Utxo[]>((subscriber) => {
            this.#utxoProvider
              .utxoByAddresses({ addresses: [this.#address.address] })
              .then((utxos) => {
                subscriber.next(utxos);
              })
              .catch((error) => subscriber.error(error));
          })
      )
    );
  }

  /**
   * Calculates and returns the total balance of the wallet.
   *
   * @returns {Observable<Cardano.Value>} An observable that emits the wallet's balance.
   */
  getBalance(): Observable<Cardano.Value> {
    return this.getUtxoSet().pipe(map((utxoSet) => coalesceValueQuantities(utxoSet.map((utxo) => utxo[1].value))));
  }

  /**
   * Retrieves and emits the transaction history of the wallet at specified polling intervals.
   *
   * @returns {Observable<Cardano.HydratedTx[]>} An observable that emits the list of historical transactions.
   */
  getTransactionHistory(): Observable<Cardano.HydratedTx[]> {
    return interval(this.#pollingInterval).pipe(
      switchMap(
        () =>
          new Observable<Cardano.HydratedTx[]>((subscriber) => {
            this.#chainHistoryProvider
              .transactionsByAddresses({
                addresses: [this.#address.address],
                pagination: {
                  limit: 25, // Gets only the first 25 transaction. This is probably good enough for the POC.
                  startAt: 0
                }
              })
              .then((paginatedTxs) => {
                subscriber.next(paginatedTxs.pageResults);
                subscriber.complete();
              })
              .catch((error) => subscriber.error(error));
          })
      )
    );
  }

  /**
   * Retrieves and emits the rewards history of the wallet's reward account at specified polling intervals.
   *
   * @returns {Observable<Map<Cardano.RewardAccount, Reward[]>>} An observable that emits the rewards history.
   */
  getRewardsHistory(): Observable<Map<Cardano.RewardAccount, Reward[]>> {
    return interval(this.#pollingInterval).pipe(
      switchMap(
        () =>
          new Observable<Map<Cardano.RewardAccount, Reward[]>>((subscriber) => {
            this.#rewardsProvider
              .rewardsHistory({
                rewardAccounts: [this.#address.rewardAccount]
              })
              .then((rewardsHistory) => {
                subscriber.next(rewardsHistory);
                subscriber.complete();
              })
              .catch((error) => subscriber.error(error));
          })
      )
    );
  }

  /**
   * Retrieves and emits the current balance of the reward account at specified polling intervals.
   *
   * @returns {Observable<Cardano.Lovelace>} An observable that emits the balance of the reward account.
   */
  getRewardAccountBalance(): Observable<Cardano.Lovelace> {
    return interval(this.#pollingInterval).pipe(
      switchMap(
        () =>
          new Observable<Cardano.Lovelace>((subscriber) => {
            this.#rewardsProvider
              .rewardAccountBalance({
                rewardAccount: this.#address.rewardAccount
              })
              .then((rewardAccountBalance) => {
                subscriber.next(rewardAccountBalance);
                subscriber.complete();
              })
              .catch((error) => subscriber.error(error));
          })
      )
    );
  }

  /**
   * Internally used method to build the multi-signature script.
   *
   * @param {Array<Crypto.Ed25519PublicKeyHex>} expectedSigners - The public keys expected to sign transactions.
   * @param {InMemoryKeyAgent} keyAgent - The in-memory key agent.
   * @returns {Promise<Cardano.NativeScript>} The constructed native script.
   */
  static async #buildScript(expectedSigners: Array<Crypto.Ed25519PublicKeyHex>, keyAgent: InMemoryKeyAgent) {
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
        keyHash: await keyAgent.bip32Ed25519.getPubKeyHash(signer),
        kind: Cardano.NativeScriptKind.RequireSignature
      });
    }

    return script;
  }

  /**
   * Internally used method to derive the wallet's grouped address from the script and network ID.
   *
   * @param {Cardano.NativeScript} script - The native script for multi-signature.
   * @param {Cardano.NetworkId} networkId - The network identifier.
   * @returns {Promise<GroupedAddress>} The derived grouped address.
   */
  static async #getAddress(script: Cardano.NativeScript, networkId: Cardano.NetworkId): Promise<GroupedAddress> {
    const scriptHash = nativeScriptPolicyId(script) as unknown as Crypto.Hash28ByteBase16;

    const scriptCredential = {
      hash: scriptHash,
      type: Cardano.CredentialType.ScriptHash
    };

    const baseAddress = Cardano.BaseAddress.fromCredentials(
      Cardano.NetworkId.Testnet,
      scriptCredential,
      scriptCredential
    );

    return {
      accountIndex: 0,
      address: baseAddress.toAddress().toBech32() as Cardano.PaymentAddress,
      index: 0,
      networkId,
      rewardAccount: Cardano.RewardAddress.fromCredentials(networkId, scriptCredential)
        .toAddress()
        .toBech32() as Cardano.RewardAccount,
      type: AddressType.External
    };
  }

  /**
   * Internally used method to create a transaction with the given outputs and certificates.
   *
   * @param {Set<Cardano.TxOut>?} txOuts - The set of transaction outputs.
   * @param {Cardano.Certificate[]?} certificates - The list of certificates to include in the transaction.
   * @returns {Promise<{ body: Cardano.TxBody, id: Cardano.TransactionId }>} The transaction body and ID.
   */
  async #createTransaction(txOuts?: Set<Cardano.TxOut>, certificates?: Cardano.Certificate[]) {
    const [protocolParameters, utxo] = await Promise.all([
      this.#networkInfoProvider.protocolParameters(),
      firstValueFrom(this.getUtxoSet())
    ]);

    const withdrawals: Cardano.Withdrawal[] = [];
    const rewardsBalance = await firstValueFrom(this.getRewardAccountBalance());

    if (rewardsBalance > 0) {
      withdrawals.push({ quantity: rewardsBalance, stakeAddress: this.getRewardAccount() });
    }

    const constraints = defaultSelectionConstraints({
      buildTx: async (inputSelection) => {
        const body: Cardano.TxBody = {
          certificates,
          fee: inputSelection.fee,
          inputs: [...inputSelection.inputs].map(([txIn]) => txIn),
          outputs: txOuts ? [...txOuts.values()] : [],
          ...(withdrawals.length > 0 ? { withdrawals } : {})
        };

        const signatureMap = new Map();

        // TODO: There is a small bug here and the fee is off by a few lovelace, this *2 will offset
        // the error in the meantime.
        for (let i = 0; i < this.#expectedSigners.length * 2; ++i)
          signatureMap.set(randomPublicKey(), DUMMY_HEX_BYTES as Crypto.Ed25519SignatureHex);

        return {
          body,
          id: '' as Cardano.TransactionId,
          witness: {
            scripts: [this.#multisigScript],
            signatures: signatureMap
          }
        };
      },
      protocolParameters,
      redeemersByType: {},
      txEvaluator: new GreedyTxEvaluator(() => this.#networkInfoProvider.protocolParameters())
    });

    const implicitCoin = Cardano.util.computeImplicitCoin(protocolParameters, {
      certificates,
      withdrawals
    });

    const { selection: inputSelection } = await this.#inputSelector.select({
      constraints,
      implicitValue: { coin: implicitCoin },
      outputs: txOuts || new Set(),
      preSelectedUtxo: new Set(),
      utxo: new Set(utxo)
    });

    const body = {
      certificates,
      fee: inputSelection.fee,
      inputs: [...inputSelection.inputs].map(([txIn]) => txIn),
      outputs: txOuts ? [...inputSelection.outputs, ...inputSelection.change] : [],
      withdrawals
    };

    const serializableBody = Serialization.TransactionBody.fromCore(body);

    const id = Cardano.TransactionId.fromHexBlob(
      util.bytesToHex(Crypto.blake2b(Crypto.blake2b.BYTES).update(util.hexToBytes(serializableBody.toCbor())).digest())
    );

    return { body, id };
  }
}
