import {
  AddressWallet,
  ApiNetworkInformationSyncProgressStatusEnum,
  ApiTransactionStatusEnum,
  TransactionWallet,
  WalletServer
} from 'cardano-wallet-js';
import { Cardano, HealthCheckResponse } from '@cardano-sdk/core';
import { FaucetProvider, FaucetRequestResult, FaucetRequestTransactionStatus } from '../types';
import { Stopwatch } from 'ts-stopwatch';
import Process from 'process';

// Constants
const FAUCET_PASSPHRASE = 'passphrase';
const FAUCET_WALLET_NAME = 'faucet';
const HTTP_ERROR_CODE_IN_CONFLICT = 409;
const DEFAULT_TIMEOUT = 10_000;
const DEFAULT_CONFIRMATIONS = 0;
const PARAM_NAME_URL = 'baseUrl';
const PARAM_NAME_MNEMONICS = 'mnemonic';

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Cardano Wallet implementation of the faucet provider. This provider utlizes the Cardano Wallet HTTP service
 * to construct, sign, submit and track the transaction generated by the faucet.
 */
export class CardanoWalletFaucetProvider implements FaucetProvider {
  #serviceUrl = '';
  #seedPhrases = '';
  #faucetWalletId = '';
  #walletServer: WalletServer;

  /**
   * Initializes a new instance of the CardanoWalletFaucetService class.
   *
   * @param url The cardano wallet server REST endpoint.
   * @param seedPhrases The seedphrases of the faucet wallet.
   */
  constructor(url: string, seedPhrases: string) {
    this.#serviceUrl = url;
    this.#seedPhrases = seedPhrases;
  }

  /**
   * Request tAda to be transferred to a single given address.
   *
   * @param address The address where the tAda must be deposited.
   * @param amount The amount of tAda to be deposited at the given address address (in lovelace).
   * @param confirmations The number of blocks that has passed since our transaction was added to the blockchain.
   * @param timeout The time we are willing to wait (in milliseconds) for the faucet request
   *                transaction to be confirmed.
   */
  public async request(
    address: string,
    amount: number,
    confirmations: number = DEFAULT_CONFIRMATIONS,
    timeout: number = DEFAULT_TIMEOUT
  ): Promise<FaucetRequestResult> {
    return this.multiRequest([address], [amount], confirmations, timeout);
  }

  /**
   * Request tAda to be transferred to the given address.
   *
   * @param addresses The addresses where the tAda must be deposited.
   * @param amounts The amounts of tAda to be deposited at each address (in lovelace).
   * @param confirmations The number of blocks that has passed since our transaction was added to the blockchain.
   * @param timeout The time we are willing to wait (in milliseconds) for the faucet request
   *                transaction to be confirmed.
   */
  public async multiRequest(
    addresses: string[],
    amounts: number[],
    confirmations: number = DEFAULT_CONFIRMATIONS,
    timeout: number = DEFAULT_TIMEOUT
  ): Promise<FaucetRequestResult> {
    const faucetWallet = await this.#walletServer.getShelleyWallet(this.#faucetWalletId);

    const receiverAddress = addresses.map((strAddress) => new AddressWallet(strAddress));

    const stopwatch = new Stopwatch();
    stopwatch.start();

    let transaction: TransactionWallet = await faucetWallet.sendPayment(FAUCET_PASSPHRASE, receiverAddress, amounts);

    let isTransactionConfirmed = false;
    while (
      (transaction.status === ApiTransactionStatusEnum.Pending || !isTransactionConfirmed) &&
      stopwatch.getTime() < timeout
    ) {
      transaction = await faucetWallet.getTransaction(transaction.id);
      isTransactionConfirmed = transaction.depth !== undefined && transaction.depth.quantity >= confirmations;
    }

    stopwatch.stop();

    if (stopwatch.getTime() >= timeout) throw new Error(`The transaction ${transaction.id} was not confirmed on time`);

    return {
      confirmations: transaction.depth?.quantity,
      id: Cardano.TransactionId(transaction.id),
      status: this.mapStatus(transaction.status),
      time: transaction.inserted_at?.time
    };
  }

  /**
   * Starts the provider.
   */
  public async start(): Promise<void> {
    const walletInfo = {
      mnemonic_sentence: this.#seedPhrases.split(' '),
      name: FAUCET_WALLET_NAME,
      passphrase: FAUCET_PASSPHRASE
    };

    this.#walletServer = WalletServer.init(this.#serviceUrl);

    const axiosResponse = await this.#walletServer.walletsApi.postWallet(walletInfo).catch((error) => {
      if (error.response === undefined) throw error;

      // This seed phrases already exists on the cardano wallet service.
      if (error.response.status === HTTP_ERROR_CODE_IN_CONFLICT) {
        // TODO: If the seedphrases were already added to Cardano Wallet, the id of the wallet
        // will be returned in an error message, we can then extract the id from the message, however
        // this extremely brittle. We must find a better way to get the wallet id given a set of seed phrases.
        this.#faucetWalletId = error.response.data.message.match(/(?<=: ).*(?= H)/g)[0];
      } else {
        throw error.response.data;
      }
    });

    if (axiosResponse) this.#faucetWalletId = axiosResponse.data.id;

    const start = Date.now() / 1000;
    const waitTime = Process.env.LOCAL_NETWORK_READY_WAIT_TIME ? Process.env.LOCAL_NETWORK_READY_WAIT_TIME : 1200;
    let isReady = false;
    let currentElapsed = 0;

    while (!isReady && currentElapsed < waitTime) {
      try {
        isReady = (await this.healthCheck()).ok;
      } catch {
        // continue
      } finally {
        currentElapsed = Date.now() / 1000 - start;
        await sleep(5000);
      }
    }

    if (currentElapsed > waitTime) {
      throw new Error('Wait time expired. The faucet was not ready on time.');
    }
  }

  /**
   * Gets the remaining balance on the faucet.
   */
  public async getBalance(): Promise<number> {
    if (this.#faucetWalletId === undefined) throw new Error('Faucet is not running.');

    const axiosResponse = await this.#walletServer.walletsApi.getWallet(this.#faucetWalletId);
    return axiosResponse.data.balance.total.quantity;
  }

  /**
   * Closes the provider.
   */
  public async close(): Promise<void> {
    this.#faucetWalletId = '';
  }

  /**
   * Performs a health check on the provider.
   *
   * @returns A promise with the healthcheck reponse.
   */
  public async healthCheck(): Promise<HealthCheckResponse> {
    const networkInfo = await this.#walletServer.getNetworkInformation();

    return {
      ok:
        networkInfo.sync_progress.status === ApiNetworkInformationSyncProgressStatusEnum.Ready &&
        this.#faucetWalletId !== '' &&
        (await this.getBalance()) > 100_000_000 // Faucet must have more than 100 tADA to be considered healthy
    };
  }

  /**
   * Converts the cardano wallet transaction result enum to our FaucetRequestTransactionStatus enum.
   *
   * @param status The cardano wallet enum to be converted.
   * @returns The FaucetRequestTransactionStatus equivalent enum value.
   */
  private mapStatus(status: ApiTransactionStatusEnum): FaucetRequestTransactionStatus {
    let mappedStatus: FaucetRequestTransactionStatus = FaucetRequestTransactionStatus.Expired;
    switch (status) {
      case ApiTransactionStatusEnum.Expired:
        mappedStatus = FaucetRequestTransactionStatus.Expired;
        break;
      case ApiTransactionStatusEnum.InLedger:
        mappedStatus = FaucetRequestTransactionStatus.InLedger;
        break;
      case ApiTransactionStatusEnum.Pending:
        mappedStatus = FaucetRequestTransactionStatus.Pending;
        break;
    }

    return mappedStatus;
  }

  /**
   * Create a new faucet provider.
   *
   * @param params The parameters to be passed to the concrete implementation constructor.
   * @returns The new Faucet provider.
   * @throws if The give provider name is not registered, or the constructor parameters of
   *         the providers are either missing or invalid.
   */
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  public static create(params: any): Promise<FaucetProvider> {
    if (!params.hasOwnProperty(PARAM_NAME_URL))
      throw new Error(`${CardanoWalletFaucetProvider.name} missing argument: ${PARAM_NAME_URL}`);

    if (!params.hasOwnProperty(PARAM_NAME_MNEMONICS))
      throw new Error(`${CardanoWalletFaucetProvider.name} missing argument: ${PARAM_NAME_MNEMONICS}`);

    return new Promise<FaucetProvider>((resolve) => {
      resolve(new CardanoWalletFaucetProvider(params[PARAM_NAME_URL], params[PARAM_NAME_MNEMONICS]));
    });
  }
}