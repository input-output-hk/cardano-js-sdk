import { Cardano } from '@cardano-sdk/core';
import { Ed25519PublicKeyHex } from '@cardano-sdk/crypto';
import { HexBlob } from '@cardano-sdk/util';
import { Runtime } from 'webextension-polyfill';

/** A hex-encoded string of the corresponding bytes. */
export type Bytes = string;

/**
 * A hex-encoded string representing CBOR either inside
 * of the Shelley Multi-asset binary spec or, if not present there,
 * from the CIP-0008 signing spec.
 */
export type Cbor = string;

/**
 *  Used to specify optional pagination for some API calls.
 *  Limits results to {limit} each page, and uses a 0-indexing {page}
 *  to refer to which of those pages of {limit} items each.
 */
export type Paginate = { page: number; limit: number };

/** DataSignature type as described in CIP-0030. */

type CoseSign1CborHex = HexBlob;
type CoseKeyCborHex = HexBlob;

export interface Cip30DataSignature {
  key: CoseKeyCborHex;
  signature: CoseSign1CborHex;
}

export type WalletApiExtension = { cip: number };

/**
 * Returns the network id of the currently connected account.
 * 0 is testnet and 1 is mainnet but other networks can possibly be returned by wallets.
 * Those other network ID values are not governed by this document.
 *
 * This result will stay the same unless the connected account has changed.
 *
 * @throws ApiError
 */
export type GetNetworkId = () => Promise<Cardano.NetworkId>;
/**
 * If `amount` is `undefined`, this shall return a list of all UTxOs (unspent transaction outputs)
 * controlled by the wallet.
 *
 * If `amount` is not `undefined`, this request shall be limited to just the UTxOs that are required
 * to reach the combined ADA/multi-asset value target specified in `amount`,
 * and if this cannot be attained, `undefined` shall be returned.
 *
 * The results can be further paginated by `paginate` if it is not `undefined`.
 *
 * @throws ApiError
 * @throws PaginateError
 */
export type GetUtxos = (amount?: Cbor, paginate?: Paginate) => Promise<Cbor[] | null>;

/**
 * @returns a list of one or more UTxOs (unspent transaction outputs) controlled by the wallet
 * that are required to reach AT LEAST the combined ADA value target specified in amount
 * AND the best suitable to be used as collateral inputs
 * for transactions with plutus script inputs (pure ADA-only UTxOs).
 * @throws ApiError
 */
export type GetCollateral = (params?: { amount?: Cbor }) => Promise<Cbor[] | null>;

/**
 * Returns the total balance available of the wallet.
 *
 * This is the same as summing the results of `api.getUtxos()`, but it is both useful to dApps
 * and likely already maintained by the implementing wallet in a more efficient manner
 * so it has been included in the API as well.
 *
 * @throws ApiError
 */
export type GetBalance = () => Promise<Cbor>;

/**
 * Retrieves the list of extensions enabled by the wallet.
 * This may be influenced by the set of extensions requested in the initial enable request.
 *
 * @throws ApiError
 */
export type GetExtensions = () => Promise<WalletApiExtension[]>;

/**
 * Returns a list of all used (included in some on-chain transaction) addresses controlled by the wallet.
 *
 * The results can be further paginated by `paginate` if it is not `undefined`.
 *
 * @throws ApiError
 * @throws PaginateError
 */
export type GetUsedAddresses = (paginate?: Paginate) => Promise<Cbor[]>;

/**
 * Returns a list of unused addresses controlled by the wallet.
 *
 * @throws ApiError
 */
export type GetUnusedAddresses = () => Promise<Cbor[]>;

/**
 * Returns an address owned by the wallet that should be used as a change address to return
 * leftover assets during transaction creation back to the connected wallet.
 *
 * This can be used as a generic receive address as well.
 *
 * @throws ApiError
 */
export type GetChangeAddress = () => Promise<Cbor>;

/**
 * Returns the reward addresses owned by the wallet. This can return multiple addresses e.g. CIP-0018.
 *
 * @throws ApiError
 */
export type GetRewardAddresses = () => Promise<Cbor[]>;

/**
 * Requests that a user sign the unsigned portions of the supplied transaction.
 *
 * The wallet should ask the user for permission, and if given,
 * try to sign the supplied body and return a signed transaction.
 *
 * If `partialSign` is `true`, the wallet only tries to sign what it can.
 *
 * If `partialSign` is `false` and the wallet could not sign the entire transaction,
 * `TxSignError` shall be returned with the `ProofGeneration` code.
 *
 * Likewise if the user declined in either case it shall return the `UserDeclined` code.
 *
 * Only the portions of the witness set that were signed as a result of this call are
 * returned to encourage dApps to verify the contents returned by this endpoint while building the final transaction.
 *
 * @throws ApiError
 * @throws TxSignError
 */
export type SignTx = (tx: Cbor, partialSign?: Boolean) => Promise<Cbor>;

/**
 * This endpoint utilizes the CIP-0008 signing spec for standardization/safety reasons.
 *
 * It allows the dApp to request the user to sign data conforming to said spec.
 *
 * The user's consent should be requested and the details of `sig_structure` shown to them in an informative way.
 *
 * Please refer to the CIP-0008 spec for details on how to construct the sig structure.
 *
 * @throws ApiError
 * @throws DataSignError
 */
export type SignData = (
  addr: Cardano.PaymentAddress | Cardano.DRepID | Bytes,
  payload: Bytes
) => Promise<Cip30DataSignature>;

/**
 * As wallets should already have this ability, we allow dApps to request that a transaction be sent through it.
 *
 * If the wallet accepts the transaction and tries to send it, it shall return the transaction id for the dApp to track.
 *
 * The wallet is free to return the `TxSendError` with code `Refused` if they do not wish to send it,
 * or `Failure` if there was an error in sending it (e.g. preliminary checks failed on signatures).
 *
 * @throws ApiError
 * @throws TxSendError
 */
export type SubmitTx = (tx: Cbor) => Promise<string>;

export interface Cip30WalletApi {
  getNetworkId: GetNetworkId;

  getUtxos: GetUtxos;

  getBalance: GetBalance;

  getCollateral: GetCollateral;

  getExtensions: GetExtensions;

  getUsedAddresses: GetUsedAddresses;

  getUnusedAddresses: GetUnusedAddresses;

  getChangeAddress: GetChangeAddress;

  getRewardAddresses: GetRewardAddresses;

  signTx: SignTx;

  signData: SignData;

  submitTx: SubmitTx;

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  experimental?: any;
}

export interface Cip95WalletApi {
  getRegisteredPubStakeKeys: () => Promise<Ed25519PublicKeyHex[]>;
  getUnregisteredPubStakeKeys: () => Promise<Ed25519PublicKeyHex[]>;
  getPubDRepKey: () => Promise<Ed25519PublicKeyHex>;
}

export type WalletApi = Cip30WalletApi & Cip95WalletApi;
export type WalletMethod = keyof WalletApi;

export interface CipExtensionApis {
  cip95: Cip95WalletApi;
}

export type Cip30WalletApiWithPossibleExtensions = Cip30WalletApi & Partial<CipExtensionApis>;

export type SenderContext = { sender: Runtime.MessageSender };
type FnWithSender<T> = T extends (...args: infer Args) => infer R ? (context: SenderContext, ...args: Args) => R : T;

export type WithSenderContext<T> = {
  [K in keyof T]: FnWithSender<T[K]>;
};
