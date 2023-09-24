/* eslint-disable sonarjs/cognitive-complexity, complexity, sonarjs/cognitive-complexity, max-statements */
import * as Cardano from '../../Cardano';
import * as Crypto from '@cardano-sdk/crypto';
import { CborReader, CborReaderState, CborWriter } from '../CBOR';
import { Certificate } from '../Certificates';
import { HexBlob } from '@cardano-sdk/util';
import { ProposalProcedure } from './ProposalProcedure';
import { SerializationError, SerializationFailure } from '../../errors';
import { TransactionInput } from './TransactionInput';
import { TransactionOutput } from './TransactionOutput';
import { Update } from '../Update';
import { VotingProcedures } from './VotingProcedures';
import { multiAssetsToTokenMap, sortCanonically, tokenMapToMultiAsset } from './Utils';

/**
 * The transaction body encapsulates the core details of a transaction.
 */
export class TransactionBody {
  // Required fields
  #inputs: Array<TransactionInput>;
  #outputs: Array<TransactionOutput>;
  #fee: Cardano.Lovelace;

  // Optional fields
  #ttl: Cardano.Slot | undefined;
  #certs: Array<Certificate> | undefined;
  #withdrawals: Map<Cardano.RewardAccount, Cardano.Lovelace> | undefined;
  #update: Update | undefined;
  #auxiliaryDataHash: Crypto.Hash32ByteBase16 | undefined;
  #validityStartInterval: Cardano.Slot | undefined;
  #mint: Cardano.TokenMap | undefined;
  #scriptDataHash: Crypto.Hash32ByteBase16 | undefined;
  #collateral: Array<TransactionInput> | undefined;
  #requiredSigners: Array<Crypto.Ed25519KeyHashHex> | undefined;
  #networkId: Cardano.NetworkId | undefined;
  #collateralReturn: TransactionOutput | undefined;
  #totalCollateral: Cardano.Lovelace | undefined;
  #referenceInputs: Array<TransactionInput> | undefined;
  #votingProcedures: VotingProcedures | undefined;
  #proposalProcedures: Array<ProposalProcedure> | undefined;
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
    inputs: Array<TransactionInput>,
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

    if (this.#inputs && this.#inputs.length > 0) {
      writer.writeInt(0n);
      writer.writeStartArray(this.#inputs.length);

      for (const input of this.#inputs) {
        writer.writeEncodedValue(Buffer.from(input.toCbor(), 'hex'));
      }
    }

    if (this.#outputs && this.#outputs.length > 0) {
      writer.writeInt(1n);
      writer.writeStartArray(this.#outputs.length);

      for (const output of this.#outputs) {
        writer.writeEncodedValue(Buffer.from(output.toCbor(), 'hex'));
      }
    }

    writer.writeInt(2n);
    writer.writeInt(this.#fee);

    if (this.#ttl) {
      writer.writeInt(3n);
      writer.writeInt(this.#ttl);
    }

    if (this.#certs && this.#certs.length > 0) {
      writer.writeInt(4n);
      writer.writeStartArray(this.#certs.length);

      for (const cert of this.#certs) {
        writer.writeEncodedValue(Buffer.from(cert.toCbor(), 'hex'));
      }
    }

    if (this.#withdrawals && this.#withdrawals.size > 0) {
      writer.writeInt(5n);

      const sortedCanonically = new Map([...this.#withdrawals].sort((a, b) => (a > b ? 1 : -1)));

      writer.writeStartMap(sortedCanonically.size);

      for (const [key, value] of sortedCanonically) {
        const rewardAddress = Cardano.RewardAddress.fromAddress(Cardano.Address.fromBech32(key));

        if (!rewardAddress) {
          throw new SerializationError(SerializationFailure.InvalidAddress, `Invalid withdrawal address: ${key}`);
        }

        writer.writeByteString(Buffer.from(rewardAddress.toAddress().toBytes(), 'hex'));
        writer.writeInt(value);
      }
    }

    if (this.#update) {
      writer.writeInt(6n);
      writer.writeEncodedValue(Buffer.from(this.#update.toCbor(), 'hex'));
    }

    if (this.#auxiliaryDataHash) {
      writer.writeInt(7n);
      writer.writeByteString(Buffer.from(this.#auxiliaryDataHash, 'hex'));
    }

    if (this.#validityStartInterval) {
      writer.writeInt(8n);
      writer.writeInt(this.#validityStartInterval);
    }

    if (this.#mint && this.#mint.size > 0) {
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

    if (this.#scriptDataHash) {
      writer.writeInt(11n);
      writer.writeByteString(Buffer.from(this.#scriptDataHash, 'hex'));
    }

    if (this.#collateral && this.#collateral.length > 0) {
      writer.writeInt(13n);

      writer.writeStartArray(this.#collateral.length);

      for (const input of this.#collateral) {
        writer.writeEncodedValue(Buffer.from(input.toCbor(), 'hex'));
      }
    }

    if (this.#requiredSigners && this.#requiredSigners.length > 0) {
      writer.writeInt(14n);

      writer.writeStartArray(this.#requiredSigners.length);

      for (const signer of this.#requiredSigners) {
        writer.writeByteString(Buffer.from(signer, 'hex'));
      }
    }

    if (this.#networkId) {
      writer.writeInt(15n);
      writer.writeInt(this.#networkId);
    }

    if (this.#collateralReturn) {
      writer.writeInt(16n);
      writer.writeEncodedValue(Buffer.from(this.#collateralReturn.toCbor(), 'hex'));
    }

    if (this.#totalCollateral) {
      writer.writeInt(17n);
      writer.writeInt(this.#totalCollateral);
    }

    if (this.#referenceInputs && this.#referenceInputs.length > 0) {
      writer.writeInt(18n);

      writer.writeStartArray(this.#referenceInputs.length);

      for (const input of this.#referenceInputs) {
        writer.writeEncodedValue(Buffer.from(input.toCbor(), 'hex'));
      }
    }

    if (this.#votingProcedures) {
      writer.writeInt(19n);
      writer.writeEncodedValue(Buffer.from(this.#votingProcedures.toCbor(), 'hex'));
    }

    if (this.#proposalProcedures && this.#proposalProcedures.length > 0) {
      writer.writeInt(20n);
      writer.writeStartArray(this.#proposalProcedures.length);

      for (const procedure of this.#proposalProcedures) {
        writer.writeEncodedValue(Buffer.from(procedure.toCbor(), 'hex'));
      }
    }

    if (this.#currentTreasuryValue) {
      writer.writeInt(21n);
      writer.writeInt(this.#currentTreasuryValue);
    }

    if (this.#donation) {
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

    const inputs: Array<TransactionInput> = new Array<TransactionInput>();
    const outputs: Array<TransactionOutput> = new Array<TransactionOutput>();
    const fee: Cardano.Lovelace = 0n;
    const body = new TransactionBody(inputs, outputs, fee);

    reader.readStartMap();

    while (reader.peekState() !== CborReaderState.EndMap) {
      const key = reader.readInt();

      switch (key) {
        case 0n: {
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            body.inputs().push(TransactionInput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();

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
          body.setTtl(Cardano.Slot(Number(reader.readInt())));
          break;
        case 4n: {
          reader.readStartArray();

          body.setCerts(new Array<Certificate>());
          while (reader.peekState() !== CborReaderState.EndArray) {
            body.certs()!.push(Certificate.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        }
        case 5n: {
          reader.readStartMap();

          body.setWithdrawals(new Map<Cardano.RewardAccount, Cardano.Lovelace>());

          while (reader.peekState() !== CborReaderState.EndMap) {
            const account = Cardano.Address.fromBytes(
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
          body.setValidityStartInterval(Cardano.Slot(Number(reader.readInt())));
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
          body.setCollateral(new Array<TransactionInput>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            body.collateral()!.push(TransactionInput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 14n:
          body.setRequiredSigners(new Array<Crypto.Ed25519KeyHashHex>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            body
              .requiredSigners()!
              .push(HexBlob.fromBytes(reader.readByteString()) as unknown as Crypto.Ed25519KeyHashHex);
          }

          reader.readEndArray();
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
          body.setReferenceInputs(new Array<TransactionInput>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            body.referenceInputs()!.push(TransactionInput.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
          break;
        case 19n:
          body.setVotingProcedures(VotingProcedures.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          break;
        case 20n:
          body.setProposalProcedures(new Array<ProposalProcedure>());
          reader.readStartArray();

          while (reader.peekState() !== CborReaderState.EndArray) {
            body.proposalProcedures()!.push(ProposalProcedure.fromCbor(HexBlob.fromBytes(reader.readEncodedValue())));
          }

          reader.readEndArray();
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
      certificates: this.#certs ? this.#certs.map((cert) => cert.toCore()) : undefined,
      collateralReturn: this.#collateralReturn?.toCore(),
      collaterals: this.#collateral ? this.#collateral.map((input) => input.toCore()) : undefined,
      donation: this.#donation,
      fee: this.#fee,
      inputs: this.#inputs.map((input) => input.toCore()),
      mint: this.#mint,
      networkId: this.#networkId,
      outputs: this.#outputs.map((output) => output.toCore()),
      proposalProcedures: this.#proposalProcedures
        ? this.#proposalProcedures.map((input) => input.toCore())
        : undefined,
      referenceInputs: this.#referenceInputs ? this.#referenceInputs.map((input) => input.toCore()) : undefined,
      requiredExtraSignatures: this.#requiredSigners,
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
      coreTransactionBody.inputs.map((input) => TransactionInput.fromCore(input)),
      coreTransactionBody.outputs.map((output) => TransactionOutput.fromCore(output)),
      coreTransactionBody.fee
    );

    if (coreTransactionBody.auxiliaryDataHash) body.setAuxiliaryDataHash(coreTransactionBody.auxiliaryDataHash);

    if (coreTransactionBody.certificates)
      body.setCerts(coreTransactionBody.certificates.map((cert) => Certificate.fromCore(cert)));

    if (coreTransactionBody.collateralReturn)
      body.setCollateralReturn(TransactionOutput.fromCore(coreTransactionBody.collateralReturn));

    if (coreTransactionBody.collaterals)
      body.setCollateral(coreTransactionBody.collaterals.map((input) => TransactionInput.fromCore(input)));

    if (coreTransactionBody.mint) body.setMint(coreTransactionBody.mint);

    if (coreTransactionBody.networkId) body.setNetworkId(coreTransactionBody.networkId);

    if (coreTransactionBody.referenceInputs)
      body.setReferenceInputs(coreTransactionBody.referenceInputs.map((input) => TransactionInput.fromCore(input)));

    if (coreTransactionBody.requiredExtraSignatures)
      body.setRequiredSigners(coreTransactionBody.requiredExtraSignatures);

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
      body.setProposalProcedures(
        coreTransactionBody.proposalProcedures.map((core) => ProposalProcedure.fromCore(core))
      );

    return body;
  }

  /**
   * Sets the list of references to UTxOs (Unspent Transaction Outputs) that the transaction intends to spend.
   * Each input refers to a previous transaction's output.
   *
   * @param inputs the list of references to UTxOs.
   */
  setInputs(inputs: Array<TransactionInput>) {
    this.#inputs = inputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the list of references to UTxOs (Unspent Transaction Outputs) that the transaction intends to spend.
   * Each input refers to a previous transaction's output.
   *
   * @returns The list of references to UTxOs.
   */
  inputs(): Array<TransactionInput> {
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
  setCerts(certs: Array<Certificate>): void {
    this.#certs = certs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the certificates to be issued by this transaction. These are used for operations.
   * For example, they can be used to register a stake key, delegate a stake, or register a stake pool.
   *
   * @returns The certificates to be issued by this transaction.
   */
  certs(): Array<Certificate> | undefined {
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
  setCollateral(collateral: Array<TransactionInput>): void {
    this.#collateral = collateral;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the UTxOs (Unspent Transaction Outputs) that a sender commits to forfeit if a
   * transaction with a Plutus script fails to execute correctly.
   *
   * @returns The UTxOs that a sender commits to forfeit.
   */
  collateral(): Array<TransactionInput> | undefined {
    return this.#collateral;
  }

  /**
   * Specifies an arbitrary set of keys which need to sign a transaction.
   *
   * @param requiredSigners The set of keys which need to sign a transaction
   */
  setRequiredSigners(requiredSigners: Array<Crypto.Ed25519KeyHashHex>): void {
    this.#requiredSigners = requiredSigners;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the set of keys which need to sign a transaction.
   *
   * @returns The set of keys which need to sign a transaction
   */
  requiredSigners(): Array<Crypto.Ed25519KeyHashHex> | undefined {
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
  setReferenceInputs(referenceInputs: Array<TransactionInput>): void {
    this.#referenceInputs = referenceInputs;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the reference inputs of this transaction.
   *
   * @returns the reference inputs.
   */
  referenceInputs(): Array<TransactionInput> | undefined {
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
  setProposalProcedures(proposalProcedure: Array<ProposalProcedure>): void {
    this.#proposalProcedures = proposalProcedure;
    this.#originalBytes = undefined;
  }

  /**
   * Gets the proposal procedures of this transaction.
   *
   * @returns the proposal procedures.
   */
  proposalProcedures(): Array<ProposalProcedure> | undefined {
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
   * Gets the size of the serialized map.
   *
   * @private
   */
  #getMapSize(): number {
    let mapSize = 0;

    if (this.#inputs !== undefined && this.#inputs.length > 0) ++mapSize;
    if (this.#outputs !== undefined && this.#inputs.length > 0) ++mapSize;
    if (this.#fee !== undefined) ++mapSize;
    if (this.#ttl !== undefined) ++mapSize;
    if (this.#certs !== undefined && this.#certs.length > 0) ++mapSize;
    if (this.#withdrawals !== undefined && this.#withdrawals.size > 0) ++mapSize;
    if (this.#update !== undefined) ++mapSize;
    if (this.#auxiliaryDataHash !== undefined) ++mapSize;
    if (this.#validityStartInterval !== undefined) ++mapSize;
    if (this.#mint !== undefined && this.#mint.size > 0) ++mapSize;
    if (this.#scriptDataHash !== undefined) ++mapSize;
    if (this.#collateral !== undefined && this.#collateral.length > 0) ++mapSize;
    if (this.#requiredSigners !== undefined && this.#requiredSigners.length > 0) ++mapSize;
    if (this.#networkId !== undefined) ++mapSize;
    if (this.#collateralReturn !== undefined) ++mapSize;
    if (this.#totalCollateral !== undefined) ++mapSize;
    if (this.#referenceInputs !== undefined && this.#referenceInputs.length > 0) ++mapSize;
    if (this.#votingProcedures !== undefined) ++mapSize;
    if (this.#proposalProcedures !== undefined && this.#proposalProcedures.length > 0) ++mapSize;
    if (this.#currentTreasuryValue !== undefined) ++mapSize;
    if (this.#donation !== undefined) ++mapSize;

    return mapSize;
  }
}
