import { Bytes, Cbor, Paginate } from '../types';
import { Cardano } from '@cardano-sdk/core';

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
export type GetUtxos = (amount?: Cbor, paginate?: Paginate) => Promise<Cardano.Utxo[] | undefined>;

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
export type SignData = (addr: Cbor, sigStructure: Cbor) => Promise<Bytes>;

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

export interface WalletApi {
  getNetworkId: GetNetworkId;

  getUtxos: GetUtxos;

  getBalance: GetBalance;

  getUsedAddresses: GetUsedAddresses;

  getUnusedAddresses: GetUnusedAddresses;

  getChangeAddress: GetChangeAddress;

  getRewardAddresses: GetRewardAddresses;

  signTx: SignTx;

  signData: SignData;

  submitTx: SubmitTx;
}
