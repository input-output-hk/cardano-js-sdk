import * as Crypto from '@cardano-sdk/crypto';
import { AuxiliaryData } from './AuxiliaryData';
import { Base64Blob, HexBlob, OpaqueString, hexStringToBuffer, usingAutoFree } from '@cardano-sdk/util';
import { CML } from '../../CML/CML';
import { Certificate } from './Certificate';
import { Datum, Script } from './Script';
import { ExUnits, ValidityInterval } from './ProtocolParameters';
import { HydratedTxIn, TxIn, TxOut } from './Utxo';
import { Lovelace, TokenMap } from './Value';
import { PartialBlockHeader } from './Block';
import { RewardAccount } from './RewardAccount';
import { TxBodyCBOR } from '../../CBOR/TxBodyCBOR';
import { bytesToHex } from '../../util/misc';

/**
 * transaction hash as hex string
 */
export type TransactionId = OpaqueString<'TransactionId'>;

/**
 * @param {string} value transaction hash as hex string
 * @throws InvalidStringError
 */
export const TransactionId = (value: string): TransactionId =>
  Crypto.Hash32ByteBase16(value) as unknown as TransactionId;
TransactionId.fromHexBlob = (value: HexBlob) => Crypto.Hash32ByteBase16.fromHexBlob<TransactionId>(value);
TransactionId.fromTxBodyCbor = (bodyCbor: TxBodyCBOR): TransactionId =>
  bytesToHex(
    usingAutoFree((scope) =>
      scope
        .manage(CML.hash_transaction(scope.manage(CML.TransactionBody.from_bytes(hexStringToBuffer(bodyCbor)))))
        .to_bytes()
    )
  ) as unknown as TransactionId;

export interface Withdrawal {
  stakeAddress: RewardAccount;
  quantity: Lovelace;
}

export interface HydratedTxBody {
  inputs: HydratedTxIn[];
  collaterals?: HydratedTxIn[];
  outputs: TxOut[];
  fee: Lovelace;
  validityInterval?: ValidityInterval;
  withdrawals?: Withdrawal[];
  certificates?: Certificate[];
  mint?: TokenMap;
  scriptIntegrityHash?: Crypto.Hash32ByteBase16;
  requiredExtraSignatures?: Crypto.Ed25519KeyHashHex[];

  /**
   * The total collateral field lets users write transactions whose collateral is evident by just looking at the
   * tx body instead of requiring information in the UTxO. The specification of total collateral is optional.
   *
   * It does not change how the collateral is computed but transactions whose collateral is different from the
   * amount specified will be invalid.
   */
  totalCollateral?: Lovelace;

  /**
   * Return collateral allows us to specify an output with the remainder of our collateral input(s) in the event
   * we over-collateralize our transaction. This allows us to avoid overpaying the collateral and also creates the
   * possibility for native assets to be also present in the collateral, though they will not serve as a payment
   * for the fee.
   */
  collateralReturn?: TxOut;

  /**
   * Reference inputs allows looking at an output without spending it. This facilitates access to information
   * stored on the blockchain without the need of spending and recreating UTXOs.
   */
  referenceInputs?: HydratedTxIn[];
}

export interface TxBody extends Omit<HydratedTxBody, 'inputs' | 'collaterals' | 'referenceInputs'> {
  inputs: TxIn[];
  collaterals?: TxIn[];
  referenceInputs?: TxIn[];
}

export enum RedeemerPurpose {
  spend = 'spend',
  mint = 'mint',
  certificate = 'certificate',
  withdrawal = 'withdrawal'
}

export interface Redeemer {
  index: number;
  purpose: RedeemerPurpose;
  data: HexBlob;
  executionUnits: ExUnits;
}

export type Signatures = Map<Crypto.Ed25519PublicKeyHex, Crypto.Ed25519SignatureHex>;

export type Signature = Crypto.Ed25519SignatureHex;
export type ChainCode = HexBlob;
export type AddressAttributes = Base64Blob;
export type VerificationKey = Crypto.Ed25519PublicKeyHex;

export interface BootstrapWitness {
  signature: Signature;
  chainCode?: ChainCode;
  addressAttributes?: AddressAttributes;
  key: VerificationKey;
}

export type Witness = {
  redeemers?: Redeemer[];
  signatures: Signatures;
  scripts?: Script[];
  bootstrap?: BootstrapWitness[];
  datums?: Datum[];
};

export interface Tx<TBody extends TxBody = TxBody> {
  id: TransactionId;
  body: TBody;
  witness: Witness;
  auxiliaryData?: AuxiliaryData;
}

export interface HydratedTx extends Tx<HydratedTxBody> {
  index: number;
  blockHeader: PartialBlockHeader;
  body: HydratedTxBody;
  txSize: number;
}

export type TxBodyWithHash = {
  hash: TransactionId;
  body: TxBody;
};
