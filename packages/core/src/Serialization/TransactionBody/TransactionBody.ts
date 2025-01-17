/* eslint-disable sonarjs/cognitive-complexity, complexity, sonarjs/cognitive-complexity, max-statements */
import * as Crypto from '@cardano-sdk/crypto';
import { Address, RewardAddress } from '../../Cardano/Address';
import { CborReader, CborReaderState, CborTag, CborWriter } from '../CBOR';
import { CborSet, Hash } from '../Common';
import { Certificate } from '../Certificates';
import { HexBlob } from '@cardano-sdk/util';
import { ProposalProcedure } from './ProposalProcedure';
import { SerializationError, SerializationFailure } from '../../errors';
import { Slot } from '../../Cardano/types/Block';
import { TransactionId } from '../../Cardano/types/Transaction';
import { TransactionInput } from './TransactionInput';
import { TransactionOutput } from './TransactionOutput';
import { Update } from '../Update';
import { VotingProcedures } from './VotingProcedures';
import { hexToBytes } from '../../util/misc';
import { multiAssetsToTokenMap, sortCanonically, tokenMapToMultiAsset } from './Utils';
import type * as Cardano from '../../Cardano';

type TransactionInputSet = CborSet<ReturnType<TransactionInput['toCore']>, TransactionInput>;

/** The transaction body encapsulates the core details of a transaction. */
export class TransactionBody {
  // Required fields
  #inputs: TransactionInputSet;
  #outputs: Array<TransactionOutput>;
  #fee: Cardano.Lovelace;

  // Optional fields
  #ttl: Cardano.Slot | undefined;
  #certs: CborSet<ReturnType<Certificate['toCore']>, Certificate> | undefined;
  #withdrawals: Map<Cardano.RewardAccount, Cardano.Lovelace> | undefined;
  #update: Update | undefined;
  #auxiliaryDataHash: Crypto.Hash32ByteBase16 | undefined;
  #validityStartInterval: Cardano.Slot | undefined;
  #mint: Cardano.TokenMap | undefined;
  #scriptDataHash: Crypto.Hash32ByteBase16 | undefined;
  #collateral: TransactionInputSet | undefined;
  #requiredSigners: CborSet<Crypto.Ed25519KeyHashHex, Hash<Crypto.Ed25519KeyHashHex>> | undefined;
  #networkId: Cardano.NetworkId | undefined;
  #collateralReturn: TransactionOutput | undefined;
  #totalCollateral: Cardano.Lovelace | undefined;
  #referenceInputs: TransactionInputSet | undefined;
  #votingProcedures: VotingProcedures | undefined;
  #proposalProcedures: CborSet<ReturnType<ProposalProcedure['toCore']>, ProposalProcedure> | undefined;
  #currentTreasuryValue: Cardano.Lovelace | undefined;
  #donation: Cardano.Lovelace | undefined;
  #originalBytes: HexBlob | undefined = undefined;

  /**
   * Initializes a new instance of the TransactionBody class.
   *
   * @param inputs A list of references to UTxOs (Unspent Transaction Outputs) that the transaction intends to spend. Each input refers to a previous transaction's output.
   * @param outputs A list of outputs where ownership of the value, including coins (ADA) and possibly other assets, will be assigned by address.
   * @param fee The amount of ADA designated as the fee for this transaction. Fees compensate stakeholders, including stake pool operators, for participating in the network.
   * @param ttl Specifies the slot number until which the transaction is valid. If the transaction isn't included in a block by this slot, it becomes invalid.
   */
  constructor(
    inputs: TransactionInputSet,
    outputs: Array<TransactionOutput>,
    fee: Cardano.Lovelace,
    ttl?: Cardano.Slot
  ) {
    this.#inputs = inputs;
    this.#outputs = outputs;
    this.#fee = fee;
    this.#ttl = ttl;
  }

  /**
   * Serializes a TransactionBody into CBOR format.
   *
   * @returns The TransactionBody in CBOR format.
   */
  toCbor(): HexBlob {
    const writer = new CborWriter();

    if (this.#originalBytes) return this.#originalBytes;

    // CDDL
    // transaction_body =
    //   { 0 : set<transaction_input>             ; inputs
    //   , 1 : [* transaction_output]
    //   , 2 : coin                               ; fee
    //   , ? 3 : uint                             ; time to live
    //   , ? 4 : [+ certificate]
    //   , ? 5 : withdrawals
    //   , ? 7 : auxiliary_data_hash
    //   , ? 8 : uint                             ; validity interval start
    //   , ? 9 : mint
    //   , ? 11 : script_data_hash
    //   , ? 13 : nonempty_set<transaction_input> ; collateral inputs
    //   , ? 14 : required_signers
    //   , ? 15 : network_id
    //   , ? 16 : transaction_output              ; collateral return
    //   , ? 17 : coin                            ; total collateral
    //   , ? 18 : nonempty_set<transaction_input> ; reference inputs
    //   , ? 19 : voting_procedures               ; New; Voting procedures
    //   , ? 20 : [+ proposal_procedure]          ; New; Proposal procedures
    //   , ? 21 : coin                            ; New; current treasury value
    //   , ? 22 : positive_coin                   ; New; donation
    //   }
    writer.writeStartMap(this.#getMapSize());

    if (this.#inputs !== undefined && this.#inputs.size() > 0) {
      writer.writeInt(0n);
      writer.writeEncodedValue(hexToBytes(this.#inputs.toCbor()));
    }

    if (this.#outputs !== undefined && this.#outputs.length > 0) {
      writer.writeInt(1n);
      writer.writeStartArray(this.#outputs.length);

      for (const output of this.#outputs) {
        writer.writeEncodedValue(Buffer.from(output.toCbor(), 'hex'));
      }
    }

    if (this.#fee !== undefined) {
      writer.writeInt(2n);
      writer.writeInt(this.#fee);
    }

    if (this.#ttl !== undefined) {
      writer.writeInt(3n);
      writer.writeInt(this.#ttl);
    }

    if (this.#certs !== undefined && this.#certs.size() > 0) {
      writer.writeInt(4n);
      writer.writeEncodedValue(hexToBytes(this.#certs.toCbor()));
    }

    if (this.#withdrawals !== undefined && this.#withdrawals.size > 0) {
      writer.writeInt(5n);
      // Create a new map with address bytes to avoid logic duplication and address checks
      const withdrawalsWithAddressBytes = new Map();
      for (const [key, value] of this.#withdrawals) {
        const rewardAddress = RewardAddress.fromAddress(Address.fromBech32(key));
        if (!rewardAddress) {
          throw new SerializationError(SerializationFailure.InvalidAddress, `Invalid withdrawal address: ${key}`);
        }
        const rewardAddressBytes = rewardAddress.toAddress().toBytes();
        withdrawalsWithAddressBytes.set(rewardAddressBytes, value);
      }

      // Sort withdrawals by address bytes, canonically
      const sortedCanonically = [...withdrawalsWithAddressBytes].sort((a, b) => (a > b ? 1 : -1));

      writer.writeStartMap(sortedCanonically.length);

      for (const [key, value] of sortedCanonically) {
        writer.writeByteString(Buffer.from(key, 'hex'));
        writer.writeInt(value);
      }
    }

    if (this.#update !== undefined) {
      writer.writeInt(6n);
      writer.writeEncodedValue(Buffer.from(this.#update.toCbor(), 'hex'));
    }

    if (this.#auxiliaryDataHash !== undefined) {
      writer.writeInt(7n);
      writer.writeByteString(Buffer.from(this.#auxiliaryDataHash, 'hex'));
    }

    if (this.#validityStartInterval !== undefined) {
      writer.writeInt(8n);
      writer.writeInt(this.#validityStartInterval);
    }

    if (this.#mint !== undefined && this.#mint.size > 0) {
      writer.writeInt(9n);

      const multiassets = tokenMapToMultiAsset(this.#mint);

      writer.writeStartMap(multiassets.size);
      const sortedMultiAssets = new Map([...multiassets!.entries()].sort(sortCanonically));

      for (const [scriptHash, assets] of sortedMultiAssets.entries()) {
        writer.writeByteString(Buffer.from(scriptHash, 'hex'));

        const sortedAssets = new Map([...assets!.entries()].sort(sortCanonically));

        writer.writeStartMap(sortedAssets.size);
        for (const [assetName, quantity] of sortedAssets.entries()) {
          writer.writeByteString(Buffer.from(assetName, 'hex'));
          writer.writeInt(quantity);
        }
      }
    }

    if (this.#scriptDataHash !== undefined) {
      writer.writeInt(11n);
      writer.writeByteString(Buffer.from(this.#scriptDataHash, 'hex'));
    }

    if (this.#collateral !== undefined && this.#collateral.size() > 0) {
      writer.writeInt(13n);
      writer.writeEncodedValue(hexToBytes(this.#collateral.toCbor()));
    }

    if (this.#requiredSigners?.values() !== undefined && this.#requiredSigners.size() > 0) {
      writer.writeInt(14n);
      writer.writeEncodedValue(hexToBytes(this.#requiredSigners.toCbor()));
    }

    if (this.#networkId !== undefined) {
      writer.writeInt(15n);
      writer.writeInt(this.#networkId);
    }

    if (this.#collateralReturn !== undefined) {
      writer.writeInt(16n);
      writer.writeEncodedValue(Buffer.from(this.#collateralReturn.toCbor(), 'hex'));
    }

    if (this.#totalCollateral !== undefined) {
      writer.writeInt(17n);
      writer.writeInt(this.#totalCollateral);
    }

    if (this.#referenceInputs !== undefined && this.#referenceInputs.size() > 0) {
      writer.writeInt(18n);
      writer.writeEncodedValue(hexToBytes(this.#referenceInputs.toCbor()));
    }

    if (this.#votingProcedures !== undefined) {
      writer.writeInt(19n);
      writer.writeEncodedValue(Buffer.from(this.#votingProcedures.toCbor(), 'hex'));
    }

    if (this.#proposalProcedures !== undefined && this.#proposalProcedures.size() > 0) {
      writer.writeInt(20n);
      writer.writeEncodedValue(hexToBytes(this.#proposalProcedures.toCbor()));
    }

    if (this.#currentTreasuryValue !== undefined) {
      writer.writeInt(21n);
      writer.writeInt(this.#currentTreasuryValue);
    }

    if (this.#donation !== undefined) {
      writer.writeInt(22n);
      writer.writeInt(this.#donation);
    }

    return writer.encodeAsHex();
  }

  /**
   * Deserializes the TransactionBody from a CBOR byte array.
   *
   * @param cbor The CBOR encoded TransactionBody object.
   * @returns The new TransactionBody instance.
   */
  static fromCbor(cbor: HexBlob): TransactionBody {
    const reader = new CborReader(cbor);

    const inputs = CborSet.fromCore([], TransactionInput.fromCore);
    const outputs: Array<TransactionOutput> = new Array<TransactionOutput>();
    const fee: Cardano.Lovelace = 0n;
    const body = new TransactionBody(inputs, outputs, fee);

    reader.readStartMap();

    while (reader.peekState() !== CborReaderState.EndMap) {
      const key = reader.readInt();

      switch (key) {
        case 0n: {
          const inputsBytes = reader.readEncodedValue();
          body.setInputs(CborSet.fromCbor(HexBlob.fromBytes(inputsBytes), TransactionInput.fromCbor));
          break;
        }
        case 1n: {
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            body.outputs().push(TransactionOutput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();

          break;
        }
        case 2n:
          body.setFee(reader.readInt());
          break;
        case 3n:
          body.setTtl(Slot(Number(reader.readInt())));
          break;
        case 4n: {
          body.setCerts(CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), Certificate.fromCbor));
          break;
        }
        case 5n: {
          reader.readStartMap();

          body.setWithdrawals(new Map<Cardano.RewardAccount, Cardano.Lovelace>());

          while (reader.peekState() !== CborReaderState.EndMap) {
            const account = Address.fromBytes(
              HexBlob.fromBytes(reader.readByteString())
            ).toBech32() as Cardano.RewardAccount;

            const amount = reader.readInt();
            body.withdrawals()!.set(account, amount);
          }

          reader.readEndMap();
          break;
        }
        case 6n:
          body.setUpdate(Update.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          break;
        case 7n:
          body.setAuxiliaryDataHash(HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash32ByteBase16);
          break;
        case 8n:
          body.setValidityStartInterval(Slot(Number(reader.readInt())));
          break;
        case 9n: {
          const multiassets = new Map<Crypto.Hash28ByteBase16, Map<Cardano.AssetName, bigint>>();

          reader.readStartMap();
          while (reader.peekState() !== CborReaderState.EndMap) {
            const scriptHash = HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash28ByteBase16;

            if (!multiassets.has(scriptHash)) multiassets.set(scriptHash, new Map<Cardano.AssetName, bigint>());

            reader.readStartMap();
            while (reader.peekState() !== CborReaderState.EndMap) {
              const assetName = Buffer.from(reader.readByteString()).toString('hex') as unknown as Cardano.AssetName;
              const quantity = reader.readInt();

              multiassets.get(scriptHash)!.set(assetName, quantity);
            }
            reader.readEndMap();
          }
          reader.readEndMap();

          body.setMint(multiAssetsToTokenMap(multiassets));
          break;
        }
        case 11n:
          body.setScriptDataHash(HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Hash32ByteBase16);
          break;
        case 13n:
          body.setCollateral(CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), TransactionInput.fromCbor));
          break;
        case 14n:
          body.setRequiredSigners(
            CborSet.fromCbor<Crypto.Ed25519KeyHashHex, Hash<Crypto.Ed25519KeyHashHex>>(
              HexBlob.fromBytes(reader.readEncodedValue()),
              Hash.fromCbor
            )
          );
          break;
        case 15n:
          body.setNetworkId(Number(reader.readInt()) as Cardano.NetworkId);
          break;
        case 16n:
          body.setCollateralReturn(TransactionOutput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          break;
        case 17n:
          body.setTotalCollateral(reader.readInt());
          break;
        case 18n:
          body.setReferenceInputs(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), TransactionInput.fromCbor)
          );
          break;
        case 19n:
          body.setVotingProcedures(VotingProcedures.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          break;
        case 20n:
          body.setProposalProcedures(
            CborSet.fromCbor(HexBlob.fromBytes(reader.readEncodedValue()), ProposalProcedure.fromCbor)
          );
          break;
        case 21n:
          body.setCurrentTreasuryValue(reader.readInt());
          break;
        case 22n:
          body.setDonation(reader.readInt());
          break;
      }
    }

    reader.readEndMap();

    body.#originalBytes = cbor;

    return body;
  }

  /**
   * Creates a Core TransactionBody object from the current TransactionBody object.
   *
   * @returns The Core TransactionBody object.
   */
  toCore(): Cardano.TxBody {
    return {
      auxiliaryDataHash: this.#auxiliaryDataHash,
      certificates: this.#certs?.values() ? this.#certs.toCore() : undefined,
      collateralReturn: this.#collateralReturn?.toCore(),
      collaterals: this.#collateral?.values() ? this.#collateral.toCore() : undefined,
      donation: this.#donation,
      fee: this.#fee,
      inputs: this.#inputs.toCore(),
      mint: this.#mint,
      networkId: this.#networkId,
      outputs: this.#outputs.map((output) => output.toCore()),
      proposalProcedures: this.#proposalProcedures?.values() ? this.#proposalProcedures.toCore() : undefined,
      referenceInputs: this.#referenceInputs?.size() ? this.#referenceInputs.toCore() : undefined,
      requiredExtraSignatures: this.#requiredSigners?.toCore(),
      scriptIntegrityHash: this.#scriptDataHash,
      totalCollateral: this.#totalCollateral,
      treasuryValue: this.#currentTreasuryValue,
      update: this.#update ? this.#update.toCore() : undefined,
      validityInterval:
        this.#ttl || this.#validityStartInterval
          ? {
              invalidBefore: this.#validityStartInterval ? this.#validityStartInterval : undefined,
              invalidHereafter: this.#ttl ? this.#ttl : undefined
            }
          : undefined,
      votingProcedures: this.#votingProcedures ? this.#votingProcedures.toCore() : undefined,
      withdrawals: this.#withdrawals
        ? [...this.#withdrawals].map(([stakeAddress, quantity]) => ({ quantity, stakeAddress }))
        : undefined
    };
  }

  /**
   * Creates a TransactionBody object from the given Core TransactionBody object.
   *
   * @param coreTransactionBody The core TransactionBody object.
   */
  static fromCore(coreTransactionBody: Cardano.TxBody): TransactionBody {
    const body = new TransactionBody(
      CborSet.fromCore(coreTransactionBody.inputs, TransactionInput.fromCore),
      // new CborSet<TransactionInput>(coreTransactionBody.inputs.map((input) => TransactionInput.fromCore(input))),
      coreTransactionBody.outputs.map((output) => TransactionOutput.fromCore(output)),
      coreTransactionBody.fee
    );

    if (coreTransactionBody.auxiliaryDataHash) body.setAuxiliaryDataHash(coreTransactionBody.auxiliaryDataHash);

    if (coreTransactionBody.certificates)
      body.setCerts(CborSet.fromCore(coreTransactionBody.certificates, Certificate.fromCore));

    if (coreTransactionBody.collateralReturn)
      body.setCollateralReturn(TransactionOutput.fromCore(coreTransactionBody.collateralReturn));

    if (coreTransactionBody.collaterals)
      body.setCollateral(CborSet.fromCore(coreTransactionBody.collaterals, TransactionInput.fromCore));

    if (coreTransactionBody.mint) body.setMint(coreTransactionBody.mint);

    if (coreTransactionBody.networkId) body.setNetworkId(coreTransactionBody.networkId);

    if (coreTransactionBody.referenceInputs)
      body.setReferenceInputs(CborSet.fromCore(coreTransactionBody.referenceInputs, TransactionInput.fromCore));

    if (coreTransactionBody.requiredExtraSignatures)
      body.setRequiredSigners(CborSet.fromCore(coreTransactionBody.requiredExtraSignatures, Hash.fromCore));

    if (coreTransactionBody.scriptIntegrityHash) body.setScriptDataHash(coreTransactionBody.scriptIntegrityHash);

    if (coreTransactionBody.totalCollateral) body.setTotalCollateral(coreTransactionBody.totalCollateral);

    if (coreTransactionBody.update) body.setUpdate(Update.fromCore(coreTransactionBody.update));

    if (coreTransactionBody.validityInterval) {
      if (coreTransactionBody.validityInterval.invalidHereafter)
        body.setTtl(coreTransactionBody.validityInterval.invalidHereafter);
      if (coreTransactionBody.validityInterval.invalidBefore)
        body.setValidityStartInterval(coreTransactionBody.validityInterval.invalidBefore);
    }

    if (coreTransactionBody.withdrawals) {
      body.setWithdrawals(new Map<Cardano.RewardAccount, Cardano.Lovelace>());

      for (const coreWithdrawal of coreTransactionBody.withdrawals) {
        body.withdrawals()!.set(coreWithdrawal.stakeAddress, coreWithdrawal.quantity);
      }
    }

    if (coreTransactionBody.donation) body.setDonation(coreTransactionBody.donation);
    if (coreTransactionBody.treasuryValue) body.setCurrentTreasuryValue(coreTransactionBody.treasuryValue);
    if (coreTransactionBody.votingProcedures)
      body.setVotingProcedures(VotingProcedures.fromCore(coreTransactionBody.votingProcedures));
    if (coreTransactionBody.proposalProcedures)
      body.setProposalProcedures(CborSet.fromCore(coreTransactionBody.proposalProcedures, ProposalProcedure.fromCore));

    return body;
  }

  /**
   * Sets the list of references to UTxOs (Unspent Transaction Outputs) that the transaction intends to spend.
   * Each input refers to a previous transaction's output.
   *
   * @param inputs the list of references to UTxOs.
   */
  setInputs(inputs: TransactionInputSet) {
    this.#inputs = inputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the list of references to UTxOs (Unspent Transaction Outputs) that the transaction intends to spend.
   * Each input refers to a previous transaction's output.
   *
   * @returns The list of references to UTxOs.
   */
  inputs() {
    return this.#inputs;
  }

  /**
   * Sets the list of outputs where the value will go.
   * Each output typically specifies an address and an amount of ADA or other tokens.
   *
   * @param outputs The list of outputs.
   */
  setOutputs(outputs: Array<TransactionOutput>) {
    this.#outputs = outputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the list of outputs where the value will go.
   * Each output specifies an address and value.
   *
   * @returns The list of outputs.
   */
  outputs(): Array<TransactionOutput> {
    return this.#outputs;
  }

  /**
   * Sets the amount of ADA designated as the fee for this transaction. Fees compensate
   * stakeholders, including stake pool operators, for participating in the network.
   *
   * @param fee The amount of ADA designated as the fee for this transaction
   */
  setFee(fee: Cardano.Lovelace) {
    this.#fee = fee;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the amount of ADA designated as the fee for this transaction. Fees compensate stakeholders,
   * including stake pool operators, for participating in the network.
   *
   * @returns The amount of ADA designated as the fee for this transaction.
   */
  fee(): Cardano.Lovelace {
    return this.#fee;
  }

  /**
   * Sets the slot number until which the transaction is valid. If the transaction isn't included in a block by
   * this slot, it becomes invalid.
   *
   * @param ttl The slot number until which the transaction is valid.
   */
  setTtl(ttl: Cardano.Slot) {
    this.#ttl = ttl;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the slot number until which the transaction is valid. If the transaction isn't included in a block by
   * this slot, it becomes invalid.
   *
   * @returns The slot number until which the transaction is valid.
   */
  ttl(): Cardano.Slot | undefined {
    return this.#ttl;
  }

  /**
   * Sets the certificates to be issued by this transaction. These are used for operations.
   * For example, they can be used to register a stake key, delegate a stake, or register a stake pool.
   *
   * @param certs The certificates to be issued by this transaction.
   */
  setCerts(certs: CborSet<ReturnType<Certificate['toCore']>, Certificate>): void {
    this.#certs = certs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the certificates to be issued by this transaction. These are used for operations.
   * For example, they can be used to register a stake key, delegate a stake, or register a stake pool.
   *
   * @returns The certificates to be issued by this transaction.
   */
  certs() {
    return this.#certs;
  }

  /**
   * Sets the list of withdrawals. This specifies from which staking addresses rewards should be withdrawn.
   *
   * @param withdrawals The list of withdrawals.
   */
  setWithdrawals(withdrawals: Map<Cardano.RewardAccount, Cardano.Lovelace>): void {
    this.#withdrawals = withdrawals;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the list of withdrawals. This specifies from which staking addresses rewards should be withdrawn.
   *
   * @returns The list of withdrawals.
   */
  withdrawals(): Map<Cardano.RewardAccount, Cardano.Lovelace> | undefined {
    return this.#withdrawals;
  }

  /**
   * Sets the protocol parameter updates. It's a way for the protocol to be updated based
   * on stakeholder input.
   *
   * @param update The protocol parameter updates.
   */
  setUpdate(update: Update): void {
    this.#update = update;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the protocol parameter updates. It's a way for the protocol to be updated based
   * on stakeholder input.
   *
   * @returns The protocol parameter updates.
   */
  update(): Update | undefined {
    return this.#update;
  }

  /**
   * Sets the hash of the auxiliary data of the transaction, such as transaction metadata.
   *
   * @param auxiliaryDataHash The hash of the auxiliary data of the transaction.
   */
  setAuxiliaryDataHash(auxiliaryDataHash: Crypto.Hash32ByteBase16): void {
    this.#auxiliaryDataHash = auxiliaryDataHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the hash of the auxiliary data of the transaction, such as transaction metadata.
   *
   * @returns The hash of the auxiliary data of the transaction.
   */
  auxiliaryDataHash(): Crypto.Hash32ByteBase16 | undefined {
    return this.#auxiliaryDataHash;
  }

  /**
   * Sets the validity interval for this transaction. Introduced in the Alonzo era, this specifies the earliest
   * slot in which the transaction is valid. It's like the inverse of TTL.
   *
   * @param validityStartInterval The earliest slot in which the transaction is valid.
   */
  setValidityStartInterval(validityStartInterval: Cardano.Slot): void {
    this.#validityStartInterval = validityStartInterval;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the validity interval for this transaction. Introduced in the Alonzo era, this specifies the earliest
   * slot in which the transaction is valid. It's like the inverse of TTL.
   *
   * @returns The earliest slot in which the transaction is valid.
   */
  validityStartInterval(): Cardano.Slot | undefined {
    return this.#validityStartInterval;
  }

  /**
   * Sets details about the tokens being minted or burned in the transaction.
   *
   * @param mint The list of tokens being minted or burned.
   */
  setMint(mint: Cardano.TokenMap): void {
    // We need to segregate the token map as a multiasset to be able to sort it correctly in canonical form.
    this.#mint = multiAssetsToTokenMap(new Map([...tokenMapToMultiAsset(mint!).entries()].sort(sortCanonically)));

    this.#originalBytes = undefined;
  }

  /**
   * Gets details about the tokens being minted or burned in the transaction.
   *
   * @returns The list of tokens being minted or burned.
   */
  mint(): Cardano.TokenMap | undefined {
    return this.#mint;
  }

  /**
   * Sets the script data integrity hash.
   *
   * @param scriptDataHash The script data integrity hash.
   */
  setScriptDataHash(scriptDataHash: Crypto.Hash32ByteBase16): void {
    this.#scriptDataHash = scriptDataHash;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the script data integrity hash.
   *
   * @returns The script data integrity hash.
   */
  scriptDataHash(): Crypto.Hash32ByteBase16 | undefined {
    return this.#scriptDataHash;
  }

  /**
   * Sets the UTxOs (Unspent Transaction Outputs) that a sender commits to forfeit if a
   * transaction with a Plutus script fails to execute correctly.
   *
   * @param collateral The UTxOs that a sender commits to forfeit.
   */
  setCollateral(collateral: TransactionInputSet): void {
    this.#collateral = collateral;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the UTxOs (Unspent Transaction Outputs) that a sender commits to forfeit if a
   * transaction with a Plutus script fails to execute correctly.
   *
   * @returns The UTxOs that a sender commits to forfeit.
   */
  collateral() {
    return this.#collateral;
  }

  /**
   * Specifies an arbitrary set of keys which need to sign a transaction.
   *
   * @param requiredSigners The set of keys which need to sign a transaction
   */
  setRequiredSigners(requiredSigners: CborSet<Crypto.Ed25519KeyHashHex, Hash<Crypto.Ed25519KeyHashHex>>): void {
    this.#requiredSigners = requiredSigners;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of keys which need to sign a transaction.
   *
   * @returns The set of keys which need to sign a transaction
   */
  requiredSigners() {
    return this.#requiredSigners;
  }

  /**
   * Sets the network id on this transaction. This is an identifier used to distinguish
   * between different networks.
   *
   * @param networkId The id of the network this transaction is intended for.
   */
  setNetworkId(networkId: Cardano.NetworkId): void {
    this.#networkId = networkId;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the network id on this transaction. This is an identifier used to distinguish
   * between different networks.
   *
   * @returns The id of the network this transaction is intended for.
   */
  networkId(): Cardano.NetworkId | undefined {
    return this.#networkId;
  }

  /**
   * Return collateral allows us to specify an output with the remainder of our collateral input(s) in the event
   * we over-collateralize our transaction. This allows us to avoid overpaying the collateral and also creates the
   * possibility for native assets to be also present in the collateral, though they will not serve as a payment
   * for the fee.
   *
   * @param collateralReturn A type of change output specifically for collateral. Include this if the collateral
   * input has an excess of ADA or includes other assets.
   */
  setCollateralReturn(collateralReturn: TransactionOutput): void {
    this.#collateralReturn = collateralReturn;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the collateral return.
   *
   * @returns An output with the remainder of our collateral input(s) in the event
   * we over-collateralize our transaction.
   */
  collateralReturn(): TransactionOutput | undefined {
    return this.#collateralReturn;
  }

  /**
   * The total collateral field lets users write transactions whose collateral is evident by just looking at the
   * tx body instead of requiring information in the UTxO. The specification of total collateral is optional.
   *
   * It does not change how the collateral is computed but transactions whose collateral is different from the
   * amount specified will be invalid.
   *
   * @param totalCollateral The total collateral amount.
   */
  setTotalCollateral(totalCollateral: Cardano.Lovelace): void {
    this.#totalCollateral = totalCollateral;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the total collateral amount.
   *
   * @returns The total collateral amount.
   */
  totalCollateral(): Cardano.Lovelace | undefined {
    return this.#totalCollateral;
  }

  /**
   * Reference inputs allows looking at an output without spending it. This facilitates access to information
   * stored on the blockchain without the need of spending and recreating UTxOs.
   */
  setReferenceInputs(referenceInputs: TransactionInputSet): void {
    this.#referenceInputs = referenceInputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the reference inputs of this transaction.
   *
   * @returns the reference inputs.
   */
  referenceInputs() {
    return this.#referenceInputs;
  }

  /**
   * Sets the voting procedures of this transaction.
   *
   * @param votingProcedures the voting procedures.
   */
  setVotingProcedures(votingProcedures: VotingProcedures): void {
    this.#votingProcedures = votingProcedures;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the voting procedures of this transaction.
   *
   * @returns the voting procedures.
   */
  votingProcedures(): VotingProcedures | undefined {
    return this.#votingProcedures;
  }

  /**
   * Sets the proposal procedures of this transaction.
   *
   * @param proposalProcedure the proposal procedures.
   */
  setProposalProcedures(proposalProcedure: CborSet<ReturnType<ProposalProcedure['toCore']>, ProposalProcedure>): void {
    this.#proposalProcedures = proposalProcedure;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the proposal procedures of this transaction.
   *
   * @returns the proposal procedures.
   */
  proposalProcedures() {
    return this.#proposalProcedures;
  }

  /**
   * Sets the current treasury value of this transaction.
   *
   * @param currentTreasuryValue the current treasury value.
   */
  setCurrentTreasuryValue(currentTreasuryValue: Cardano.Lovelace): void {
    this.#currentTreasuryValue = currentTreasuryValue;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the current treasury value of this transaction.
   *
   * @returns the current treasury value.
   */
  currentTreasuryValue(): Cardano.Lovelace | undefined {
    return this.#currentTreasuryValue;
  }

  /**
   * Sets the current treasury donation of this transaction.
   *
   * @param donation The treasury donation.
   */
  setDonation(donation: Cardano.Lovelace): void {
    this.#donation = donation;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the current treasury donation of this transaction.
   *
   * @returns The treasury donation.
   */
  donation(): Cardano.Lovelace | undefined {
    return this.#donation;
  }

  /**
   * Computes the hash of the transaction body.
   *
   * @returns The hash of the transaction body.
   */
  hash() {
    const hash = Crypto.blake2b(Crypto.blake2b.BYTES).update(hexToBytes(this.toCbor())).digest();
    return TransactionId.fromHexBlob(HexBlob.fromBytes(hash));
  }

  /**
   * Checks if the transaction body has tagged sets.
   *
   * @returns true if the transaction body has tagged sets, false otherwise.
   */
  hasTaggedSets() {
    const reader = new CborReader(this.#inputs.toCbor());
    return reader.peekState() === CborReaderState.Tag && reader.peekTag() === CborTag.Set;
  }

  /**
   * Gets the size of the serialized map.
   *
   * @private
   */
  #getMapSize(): number {
    let mapSize = 0;

    if (this.#inputs !== undefined && this.#inputs.size() > 0) ++mapSize;
    if (this.#outputs !== undefined && this.#outputs.length > 0) ++mapSize;
    if (this.#fee !== undefined) ++mapSize;
    if (this.#ttl !== undefined) ++mapSize;
    if (this.#certs !== undefined && this.#certs.size() > 0) ++mapSize;
    if (this.#withdrawals !== undefined && this.#withdrawals.size > 0) ++mapSize;
    if (this.#update !== undefined) ++mapSize;
    if (this.#auxiliaryDataHash !== undefined) ++mapSize;
    if (this.#validityStartInterval !== undefined) ++mapSize;
    if (this.#mint !== undefined && this.#mint.size > 0) ++mapSize;
    if (this.#scriptDataHash !== undefined) ++mapSize;
    if (this.#collateral !== undefined && this.#collateral.size() > 0) ++mapSize;
    if (this.#requiredSigners?.values() !== undefined && this.#requiredSigners.size() > 0) ++mapSize;
    if (this.#networkId !== undefined) ++mapSize;
    if (this.#collateralReturn !== undefined) ++mapSize;
    if (this.#totalCollateral !== undefined) ++mapSize;
    if (this.#referenceInputs !== undefined && this.#referenceInputs.size() > 0) ++mapSize;
    if (this.#votingProcedures !== undefined) ++mapSize;
    if (this.#proposalProcedures !== undefined && this.#proposalProcedures.size() > 0) ++mapSize;
    if (this.#currentTreasuryValue !== undefined) ++mapSize;
    if (this.#donation !== undefined) ++mapSize;

    return mapSize;
  }
}
