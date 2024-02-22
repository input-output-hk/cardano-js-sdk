import * as Crypto from '@cardano-sdk/crypto';
import { AuxiliaryData } from './AuxiliaryData';
import { Base64Blob, HexBlob, OpaqueString } from '@cardano-sdk/util';
import { Certificate, PoolRegistrationCertificate } from './Certificate';
import { ExUnits, Update, ValidityInterval } from './ProtocolParameters';
import { HydratedTxIn, TxIn, TxOut } from './Utxo';
import { Lovelace, TokenMap } from './Value';
import { NetworkId } from '../ChainId';
import { PartialBlockHeader } from './Block';
import { PlutusData } from './PlutusData';
import { ProposalProcedure, VotingProcedures } from './Governance';
import { RewardAccount } from '../Address';
import { Script } from './Script';
import { TxBodyCBOR } from '../../CBOR/TxBodyCBOR';
import { bytesToHex, hexToBytes } from '../../util/misc';

/** transaction hash as hex string */
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
    Crypto.blake2b(Crypto.blake2b.BYTES)
      .update(hexToBytes(bodyCbor as unknown as HexBlob))
      .digest()
  ) as unknown as TransactionId;

export interface Withdrawal {
  stakeAddress: RewardAccount;
  quantity: Lovelace;
}

export type HydratedPoolRegistrationCertificate = PoolRegistrationCertificate & { deposit?: Lovelace };

export type HydratedCertificate =
  | Exclude<Certificate, PoolRegistrationCertificate>
  | HydratedPoolRegistrationCertificate;

export interface HydratedTxBody {
  inputs: HydratedTxIn[];
  collaterals?: HydratedTxIn[];
  outputs: TxOut[];
  fee: Lovelace;
  validityInterval?: ValidityInterval;
  withdrawals?: Withdrawal[];
  certificates?: HydratedCertificate[];
  mint?: TokenMap;
  scriptIntegrityHash?: Crypto.Hash32ByteBase16;
  requiredExtraSignatures?: Crypto.Ed25519KeyHashHex[];
  networkId?: NetworkId;
  update?: Update;
  auxiliaryDataHash?: Crypto.Hash32ByteBase16;

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

  votingProcedures?: VotingProcedures;
  proposalProcedures?: ProposalProcedure[];
  treasuryValue?: Lovelace;
  donation?: Lovelace;
}

export interface TxBody extends Omit<HydratedTxBody, 'certificates' | 'inputs' | 'collaterals' | 'referenceInputs'> {
  certificates?: Certificate[];
  collaterals?: TxIn[];
  inputs: TxIn[];
  referenceInputs?: TxIn[];
}

export enum InputSource {
  inputs = 'inputs',
  collaterals = 'collaterals'
}

export enum RedeemerPurpose {
  spend = 'spend',
  mint = 'mint',
  certificate = 'certificate',
  withdrawal = 'withdrawal',
  delegateRepresentative = 'representative',
  propose = 'propose',
  vote = 'vote'
}

export interface Redeemer {
  index: number;
  purpose: RedeemerPurpose;
  data: PlutusData;
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
  datums?: PlutusData[];
};

export interface Tx<TBody extends TxBody = TxBody> {
  id: TransactionId;
  body: TBody;
  witness: Witness;
  auxiliaryData?: AuxiliaryData;
  /**
   * Transactions containing Plutus scripts that are expected to fail validation can still be submitted if
   * this value is set to false.
   *
   * Remark: Sending transactions with invalid scripts will cause the collateral of the transaction to be lost.
   */
  isValid?: boolean;
}

interface TxWithInputSource<TBody extends TxBody = TxBody> extends Omit<Tx<TBody>, 'isValid'> {
  inputSource: InputSource;
}

// https://github.com/input-output-hk/cardano-js-sdk/pull/927#discussion_r1352081210
export interface OnChainTx<TBody extends TxBody = TxBody>
  extends Omit<TxWithInputSource<TBody>, 'witness' | 'auxiliaryData'> {
  witness: Omit<Witness, 'scripts'>;
  auxiliaryData?: Omit<AuxiliaryData, 'scripts'>;
}

export interface HydratedTx extends TxWithInputSource<HydratedTxBody> {
  index: number;
  blockHeader: PartialBlockHeader;
  body: HydratedTxBody;
  txSize: number;
}

export type TxBodyWithHash = {
  hash: TransactionId;
  body: TxBody;
};
