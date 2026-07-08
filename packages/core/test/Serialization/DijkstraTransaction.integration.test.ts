import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '../../src';
import { GuardsKind, Transaction, TxCBOR } from '../../src/Serialization';
import { HexBlob } from '@cardano-sdk/util';
import { NativeScriptKind, PlutusLanguageVersion, RedeemerPurpose, ScriptType } from '../../src/Cardano';
import { rewardAccount, signature, txIn, vkey } from './testData';

// eslint-disable-next-line max-len
const MAX_TX_HEX =
  '84b700d90102818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5000182825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc1a00989680a3005839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc011a001e848003d8184a82044746010000220013021a00030d400319271004d901028183028200581c00112233445566778899aabbccddeeff00112233445566778899aabb581cd85087c646951407198c27b1b950fd2e99f28586c000ce39f6e6ef9205a1581de013cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d0050758209e2e4ea189a571107fddaa2459ad14241a080c0142c02c89e4070cf71e87825108186409a2581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a14014581c659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82a14454534c4138310b58206199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de0dd90102818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5010ed90102828200581c00112233445566778899aabbccddeeff00112233445566778899aabb8201581caabbccddeeff00112233445566778899aabbccddeeff0011223344550f0010825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc1a003d0900111a004c4b4012d90102818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d50313a18202581c00112233445566778899aabbccddeeff00112233445566778899aabba1825820ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25008201827368747470733a2f2f6578616d706c652e636f6d5820000000000000000000000000000000000000000000000000000000000000000014d9010281841a000f4240581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f8400825820ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e2500a700186412a103831a0003236119032c011821d81e8218590218221a004c4b4018231a000f424018241964001825d81e820302f6827368747470733a2f2f6578616d706c652e636f6d58200000000000000000000000000000000000000000000000000000000000000000151a00989680161903e817d901028283a600d90102818258200f3abbc8fc19c2e61bab6059bf8a466e6e754833a08a62a6c56fe0e78f19d9d5020181825839009493315cd92eb5d8c4304e67b7e16ae36d61d34502694657811a2c8e32c728d3861e164cab28cb8f006448139c8f1740ffb8e7aa9e5232dc1a002dc6c004d901028183078200581c00112233445566778899aabbccddeeff00112233445566778899aabb1a001e848005a1581de013cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d00509a1581c2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740a1401903e81818a28200581c00112233445566778899aabbccddeeff00112233445566778899aabbf68201581caabbccddeeff00112233445566778899aabbccddeeff001122334455d87980a0f683a200d90102800180a0a10164746573741819a2581de013cf55d175ea848b87deb3e914febd7e028e2bf6534475d52fb9c3d01a001e8480581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f1a000f4240181aa38200581c00112233445566778899aabbccddeeff00112233445566778899aabb821901f4f68200581cffeeddccbbaa99887766554433221100ffeeddccbbaa9988776655448218641913888201581caabbccddeeff00112233445566778899aabbccddeeff00112233445582f6192710a800d90102818258206199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d395840bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c8918755bdea87fca1b4b4df8a9b8fb4183c0fab2f8261eb6c5e4bc42c800bb9c891875501d901028182068200581c00112233445566778899aabbccddeeff00112233445566778899aabb02d9010281845820deeb8f82f2af5836ebbc1b450b6dbf0b03c93afe5696f10d49e8a8304ebfac01584064676273786767746f6768646a7074657476746b636f6376796669647171676775726a687268716169697370717275656c6876797071786565777072796676775820b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b45041a003d9010281474601000022001004d9010281187b05a282000082d87a9f187bff82190bb8191b5882060082d87a9f187bff821913881907d006d9010281474601000022001107d90102814746010000220012f5d90103a600a11902d17064696a6b737472612d6d6178696d616c01818200581cb5ae663aaea8e500157bdf4baafd6f5ba0ce5759f7cd4101fc132f54028147460100002200100381474601000022001104814746010000220012058247460100002200134747010000222200';

const IN_BLOCK_TX_HEX = `83${MAX_TX_HEX.slice(2).replace('f5d90103', 'd90103')}`;

const EXPECTED_TX_ID = Cardano.TransactionId('18c280e11b5c64e36a783da547aab8602b475abab01828256b435a799eb28526');

const KEY_HASH = Crypto.Hash28ByteBase16('00112233445566778899aabbccddeeff00112233445566778899aabb');
const SCRIPT_HASH = Crypto.Hash28ByteBase16('aabbccddeeff00112233445566778899aabbccddeeff001122334455');
const OTHER_KEY_HASH = Crypto.Hash28ByteBase16('ffeeddccbbaa99887766554433221100ffeeddccbbaa998877665544');

const paymentAddress = Cardano.PaymentAddress(
  'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
);
const testRewardAccount = Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27');
const governanceActionTxId = Cardano.TransactionId('ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25');

describe('Dijkstra maximal transaction integration', () => {
  const tx = Transaction.fromCbor(TxCBOR(MAX_TX_HEX));
  const core = tx.toCore();
  const body = core.body;

  describe('required round trip assertions', () => {
    it('round trips the mempool frame byte-exactly', () => {
      expect(Transaction.fromCbor(TxCBOR(MAX_TX_HEX)).toCbor()).toEqual(MAX_TX_HEX);
    });

    it('re-encodes byte-exactly from core, not just from the original-bytes cache', () => {
      expect(Transaction.fromCore(core).toCbor()).toEqual(MAX_TX_HEX);
    });

    it('is deeply symmetric across toCore -> fromCore -> toCore', () => {
      expect(Transaction.fromCore(core).toCore()).toEqual(core);
    });

    it('keeps the transaction id stable across re-encode', () => {
      const reEncoded = Transaction.fromCbor(Transaction.fromCore(core).toCbor());

      expect(tx.getId()).toEqual(EXPECTED_TX_ID);
      expect(reEncoded.getId()).toEqual(EXPECTED_TX_ID);
      expect(Transaction.fromCore(core).getId()).toEqual(EXPECTED_TX_ID);
    });

    it('decodes cleanly in strict mode (every body and witness set key is known)', () => {
      expect(() => Transaction.fromCbor(TxCBOR(MAX_TX_HEX), { strict: true })).not.toThrow();
    });
  });

  describe('transaction frame', () => {
    it('is the 4-element grace-period frame with the literal true', () => {
      expect(MAX_TX_HEX.startsWith('84')).toBe(true);
      expect(tx.isValid()).toBe(true);
      expect(core.isValid).toBe(true);
    });

    it('derives the 3-element in-block frame from the same components', () => {
      const derived = `83${tx.body().toCbor()}${tx.witnessSet().toCbor()}${tx.auxiliaryData()!.toCbor()}`;

      expect(derived).toEqual(IN_BLOCK_TX_HEX);
    });

    it('round trips the in-block frame byte-exactly and re-encodes it as the mempool frame', () => {
      const inBlock = Transaction.fromCbor(TxCBOR(IN_BLOCK_TX_HEX));
      const rebuilt = new Transaction(inBlock.body(), inBlock.witnessSet(), inBlock.auxiliaryData());

      expect(inBlock.toCbor()).toEqual(IN_BLOCK_TX_HEX);
      expect(inBlock.getId()).toEqual(EXPECTED_TX_ID);
      expect(rebuilt.toCbor()).toEqual(MAX_TX_HEX);
    });
  });

  describe('body, standard fields', () => {
    it('has the expected inputs, outputs, fee and validity interval', () => {
      expect(body.inputs).toEqual([txIn]);
      expect(body.outputs).toHaveLength(2);
      expect(body.outputs[0]).toEqual({ address: paymentAddress, value: { coins: 10_000_000n } });
      expect(body.fee).toEqual(200_000n);
      expect(body.validityInterval).toEqual({
        invalidBefore: Cardano.Slot(100),
        invalidHereafter: Cardano.Slot(10_000)
      });
    });

    it('carries a Plutus V4 reference script in the second output', () => {
      expect(body.outputs[1]).toEqual({
        address: paymentAddress,
        scriptReference: {
          __type: ScriptType.Plutus,
          bytes: HexBlob('46010000220013'),
          version: PlutusLanguageVersion.V4
        },
        value: { coins: 2_000_000n }
      });
    });

    it('has a certificate, a withdrawal and a two-entry mint', () => {
      expect(body.certificates).toEqual([
        {
          __typename: Cardano.CertificateType.StakeDelegation,
          poolId: Cardano.PoolId('pool1mpgg03jxj52qwxvvy7cmj58a96vl9pvxcqqvuw0kumheygxmn34'),
          stakeCredential: { hash: KEY_HASH, type: Cardano.CredentialType.KeyHash }
        }
      ]);
      expect(body.withdrawals).toEqual([{ quantity: 5n, stakeAddress: testRewardAccount }]);
      expect(body.mint!.get(Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'))).toEqual(20n);
      expect(
        body.mint!.get(Cardano.AssetId('659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba8254534c41'))
      ).toEqual(-50n);
    });

    it('pins the auxiliary data hash to the blake2b-256 of the auxiliary data bytes', () => {
      expect(body.auxiliaryDataHash).toEqual(
        Crypto.blake2b.hash<Crypto.Hash32ByteBase16>(tx.auxiliaryData()!.toCbor(), 32)
      );
    });

    it('has script data hash, collateral, collateral return, total collateral and reference inputs', () => {
      expect(body.scriptIntegrityHash).toEqual(
        Crypto.Hash32ByteBase16('6199186adb51974690d7247d2646097d2c62763b16fb7ed3f9f55d38abc123de')
      );
      expect(body.collaterals).toEqual([{ ...txIn, index: 1 }]);
      expect(body.collateralReturn).toEqual({ address: paymentAddress, value: { coins: 4_000_000n } });
      expect(body.totalCollateral).toEqual(5_000_000n);
      expect(body.referenceInputs).toEqual([{ ...txIn, index: 3 }]);
    });

    it('has network id, treasury value and donation', () => {
      expect(body.networkId).toEqual(Cardano.NetworkId.Testnet);
      expect(body.treasuryValue).toEqual(10_000_000n);
      expect(body.donation).toEqual(1000n);
    });
  });

  describe('body key 14 guards, credential form', () => {
    it('exposes the mixed key hash + script hash credential oset', () => {
      expect(body.guards).toEqual([
        { hash: KEY_HASH, type: Cardano.CredentialType.KeyHash },
        { hash: SCRIPT_HASH, type: Cardano.CredentialType.ScriptHash }
      ]);
    });

    it('derives requiredExtraSignatures from the key hash guards only', () => {
      expect(body.requiredExtraSignatures).toEqual([Crypto.Ed25519KeyHashHex(KEY_HASH)]);
    });

    it('decodes as credential form guards, not legacy required signers', () => {
      const serializationBody = tx.body();

      expect(serializationBody.requiredSigners()).toBeUndefined();
      expect(serializationBody.guards()).toBeDefined();
      expect(serializationBody.guards()!.kind()).toEqual(GuardsKind.Credentials);
      expect(serializationBody.guards()!.size()).toEqual(2);
    });
  });

  describe('body key 23 sub transactions', () => {
    const subTransactions = body.subTransactions!;

    it('carries exactly two sub transactions with distinct ids', () => {
      const serializationSubs = tx.body().subTransactions()!.values();

      expect(subTransactions).toHaveLength(2);
      expect(serializationSubs).toHaveLength(2);
      expect(serializationSubs[0].getId()).not.toEqual(serializationSubs[1].getId());
    });

    it('first sub transaction carries certs, withdrawals and mint', () => {
      const richBody = subTransactions[0].body;

      expect(richBody.inputs).toEqual([{ ...txIn, index: 2 }]);
      expect(richBody.outputs).toEqual([{ address: paymentAddress, value: { coins: 3_000_000n } }]);
      expect(richBody.certificates).toEqual([
        {
          __typename: Cardano.CertificateType.Registration,
          deposit: 2_000_000n,
          stakeCredential: { hash: KEY_HASH, type: Cardano.CredentialType.KeyHash }
        }
      ]);
      expect(richBody.withdrawals).toEqual([{ quantity: 5n, stakeAddress: testRewardAccount }]);
      expect(richBody.mint!.get(Cardano.AssetId('2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740'))).toEqual(
        1000n
      );
    });

    it('first sub transaction carries key 24 required_top_level_guards with a null and a real datum', () => {
      const guards = subTransactions[0].body.requiredTopLevelGuards!;

      expect(guards).toHaveLength(2);
      expect(guards[0].credential).toEqual({ hash: KEY_HASH, type: Cardano.CredentialType.KeyHash });
      expect(guards[0].datum).toBeNull();
      expect(guards[1].credential).toEqual({ hash: SCRIPT_HASH, type: Cardano.CredentialType.ScriptHash });
      expect(guards[1].datum).toEqual(expect.objectContaining({ constructor: 0n }));
    });

    it('second sub transaction is minimal and carries auxiliary data', () => {
      const minimal = subTransactions[1];

      expect(minimal.body.inputs).toEqual([]);
      expect(minimal.body.outputs).toEqual([]);
      expect(minimal.auxiliaryData!.blob!.get(1n)).toEqual('test');
      expect(subTransactions[0].auxiliaryData).toBeUndefined();
    });

    it('sub transaction bodies have no fee key (paid by the enclosing transaction)', () => {
      expect('fee' in subTransactions[0].body).toBe(false);
      expect('fee' in subTransactions[1].body).toBe(false);
    });
  });

  describe('body key 25 direct deposits', () => {
    it('carries two direct deposit entries', () => {
      expect(body.directDeposits).toHaveLength(2);
      expect(body.directDeposits).toContainEqual({ quantity: 1_000_000n, stakeAddress: rewardAccount });
      expect(body.directDeposits).toContainEqual({ quantity: 2_000_000n, stakeAddress: testRewardAccount });
    });
  });

  describe('body key 26 account balance intervals', () => {
    const intervals = body.accountBalanceIntervals!;
    const intervalFor = (hash: Crypto.Hash28ByteBase16) => intervals.find((entry) => entry.credential.hash === hash)!;

    it('carries all three interval shapes across three credentials', () => {
      expect(intervals).toHaveLength(3);
      expect(intervalFor(KEY_HASH)).toEqual({
        credential: { hash: KEY_HASH, type: Cardano.CredentialType.KeyHash },
        interval: { inclusiveLowerBound: 500n }
      });
      expect(intervalFor(SCRIPT_HASH)).toEqual({
        credential: { hash: SCRIPT_HASH, type: Cardano.CredentialType.ScriptHash },
        interval: { exclusiveUpperBound: 10_000n }
      });
      expect(intervalFor(OTHER_KEY_HASH)).toEqual({
        credential: { hash: OTHER_KEY_HASH, type: Cardano.CredentialType.KeyHash },
        interval: { exclusiveUpperBound: 5000n, inclusiveLowerBound: 100n }
      });
    });
  });

  describe('body keys 19/20 governance', () => {
    it('carries a voting procedure with a dRep key hash voter', () => {
      expect(body.votingProcedures).toEqual([
        {
          voter: {
            __typename: Cardano.VoterType.dRepKeyHash,
            credential: { hash: KEY_HASH, type: Cardano.CredentialType.KeyHash }
          },
          votes: [
            {
              actionId: { actionIndex: 0, id: governanceActionTxId },
              votingProcedure: {
                anchor: {
                  dataHash: Crypto.Hash32ByteBase16('0000000000000000000000000000000000000000000000000000000000000000'),
                  url: 'https://example.com'
                },
                vote: Cardano.Vote.yes
              }
            }
          ]
        }
      ]);
    });

    it('carries a parameter change proposal with protocol param update keys 34-37 and a V4 cost model', () => {
      expect(body.proposalProcedures).toHaveLength(1);
      const procedure = body.proposalProcedures![0];
      const action = procedure.governanceAction as Cardano.ParameterChangeAction;

      expect(procedure.deposit).toEqual(1_000_000n);
      expect(procedure.rewardAccount).toEqual(rewardAccount);
      expect(action.__typename).toEqual(Cardano.GovernanceActionType.parameter_change_action);
      expect(action.governanceActionId).toEqual({ actionIndex: 0, id: governanceActionTxId });
      expect(action.policyHash).toBeNull();
      expect(action.protocolParamUpdate).toEqual({
        costModels: new Map([[PlutusLanguageVersion.V4, [205_665, 812, 1]]]),
        maxRefScriptSizePerBlock: 5_000_000,
        maxRefScriptSizePerTx: 1_000_000,
        minFeeCoefficient: 100,
        minFeeRefScriptCostPerByte: '44.5',
        refScriptCostMultiplier: '1.5',
        refScriptCostStride: 25_600
      });
    });
  });

  describe('witness set', () => {
    const witness = core.witness;

    it('has one vkey witness and one bootstrap witness with a 32-byte chain code', () => {
      expect(witness.signatures).toEqual(
        new Map([[Crypto.Ed25519PublicKeyHex(vkey), Crypto.Ed25519SignatureHex(signature)]])
      );
      expect(witness.bootstrap).toHaveLength(1);
      expect(witness.bootstrap![0].chainCode).toEqual(
        HexBlob('b6dbf0b03c93afe5696f10d49e8a8304ebfac01deeb8f82f2af5836ebbc1b450')
      );
    });

    it('encodes redeemers as a map including a guarding (tag 6) entry', () => {
      const redeemersCbor = tx.witnessSet().redeemers()!.toCbor();

      expect(redeemersCbor.startsWith('a2')).toBe(true);
      expect(witness.redeemers).toHaveLength(2);
      expect(witness.redeemers![0].purpose).toEqual(RedeemerPurpose.spend);
      expect(witness.redeemers![0].index).toEqual(0);
      expect(witness.redeemers![0].executionUnits).toEqual({ memory: 3000, steps: 7000 });
      expect(witness.redeemers![1].purpose).toEqual(RedeemerPurpose.guarding);
      expect(witness.redeemers![1].index).toEqual(0);
      expect(witness.redeemers![1].executionUnits).toEqual({ memory: 5000, steps: 2000 });
    });

    it('carries a require_guard (kind 6) native script', () => {
      expect(witness.scripts).toContainEqual({
        __type: ScriptType.Native,
        credential: { hash: KEY_HASH, type: Cardano.CredentialType.KeyHash },
        kind: NativeScriptKind.RequireGuard
      });
    });

    it('carries V1, V2 and V3 plutus scripts and a datum, but no V4 key', () => {
      expect(witness.scripts).toContainEqual({
        __type: ScriptType.Plutus,
        bytes: HexBlob('46010000220010'),
        version: PlutusLanguageVersion.V1
      });
      expect(witness.scripts).toContainEqual({
        __type: ScriptType.Plutus,
        bytes: HexBlob('46010000220011'),
        version: PlutusLanguageVersion.V2
      });
      expect(witness.scripts).toContainEqual({
        __type: ScriptType.Plutus,
        bytes: HexBlob('46010000220012'),
        version: PlutusLanguageVersion.V3
      });
      expect(
        witness.scripts!.some(
          (script) => script.__type === ScriptType.Plutus && script.version === PlutusLanguageVersion.V4
        )
      ).toBe(false);
      expect(witness.datums).toEqual([123n]);
    });
  });

  describe('auxiliary data with Plutus V4 scripts', () => {
    const auxiliaryData = core.auxiliaryData!;
    const scriptsOfVersion = (version: PlutusLanguageVersion) =>
      auxiliaryData.scripts!.filter((script) => script.__type === ScriptType.Plutus && script.version === version);

    it('carries metadata and one script list per language', () => {
      expect(auxiliaryData.blob!.get(721n)).toEqual('dijkstra-maximal');
      expect(auxiliaryData.scripts!.filter((script) => script.__type === ScriptType.Native)).toHaveLength(1);
      expect(scriptsOfVersion(PlutusLanguageVersion.V1)).toHaveLength(1);
      expect(scriptsOfVersion(PlutusLanguageVersion.V2)).toHaveLength(1);
      expect(scriptsOfVersion(PlutusLanguageVersion.V3)).toHaveLength(1);
    });

    it('carries two Plutus V4 scripts at auxiliary data map key 5', () => {
      const v4Scripts = tx.auxiliaryData()!.plutusV4Scripts()!;

      expect(scriptsOfVersion(PlutusLanguageVersion.V4)).toEqual([
        { __type: ScriptType.Plutus, bytes: HexBlob('46010000220013'), version: PlutusLanguageVersion.V4 },
        { __type: ScriptType.Plutus, bytes: HexBlob('47010000222200'), version: PlutusLanguageVersion.V4 }
      ]);
      expect(v4Scripts).toHaveLength(2);
      expect(v4Scripts[0].rawBytes()).toEqual(HexBlob('46010000220013'));
      expect(v4Scripts[1].rawBytes()).toEqual(HexBlob('47010000222200'));
    });
  });
});
