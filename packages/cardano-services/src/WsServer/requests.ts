// cSpell:ignore unreg

import { Cardano, CardanoNode, CardanoNodeUtil } from '@cardano-sdk/core';
import { Hash28ByteBase16 } from '@cardano-sdk/crypto';
import { Pool } from 'pg';
import { ProtocolParamsModel } from '../NetworkInfo/DbSyncNetworkInfoProvider/types';
import { getGovernanceAction } from '../ChainHistory';
import { mapAnchor } from '../ChainHistory/DbSyncChainHistory/mappers';
import { mapTxMetadata } from '../Metadata';
import { toProtocolParams } from '../NetworkInfo/DbSyncNetworkInfoProvider/mappers';

// Workaround for @types/pg
declare module 'pg' {
  interface QueryConfig {
    rowMode?: 'array';
  }
}

export const getLovelaceSupply = async (db: Pool, maxLovelaceSupply: Cardano.Lovelace) => {
  const query = 'SELECT utxo + rewards AS circulating, reserves FROM ada_pots ORDER BY id DESC LIMIT 1';
  const { rows } = await db.query<{ circulating: string; reserves: string }>(query);
  const [row] = rows;

  // Workaround to make this work on epoch 0 as well.
  // Once db-sync will solve this problem the "no lines found" case can be removed.
  return row
    ? { circulating: BigInt(row.circulating), total: maxLovelaceSupply - BigInt(row.reserves) }
    : { circulating: 0n, total: maxLovelaceSupply };
};

// committee_term_limit min_committee_size
export const getProtocolParameters = async (db: Pool) => {
  const query = `\
SELECT epoch_param.*, cost_model.costs FROM epoch_param
  LEFT JOIN cost_model ON cost_model.id = epoch_param.cost_model_id
  ORDER BY epoch_no DESC NULLS LAST LIMIT 1`;
  const { rows } = await db.query<ProtocolParamsModel>(query);

  return toProtocolParams(rows[0]);
};

export const getStake = async (cardanoNode: CardanoNode, db: Pool) => {
  const [live, active] = await Promise.all([
    cardanoNode.stakeDistribution().then(CardanoNodeUtil.toLiveStake),
    (async () => {
      const { rows } = await db.query<{ stake: string }>(
        'SELECT COALESCE(SUM(amount), 0) AS stake FROM epoch_stake WHERE epoch_no = (SELECT MAX(no) FROM epoch) - 1'
      );

      return BigInt(rows[0].stake);
    })()
  ]);

  return { active, live };
};

type TransactionData = [
  number,
  Buffer,
  number,
  number,
  string,
  number,
  number,
  boolean,
  Cardano.BlockNo,
  Buffer,
  Cardano.Slot
];

const transactionsData = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx.id::INTEGER,
  tx.hash,
  block_index,
  tx.size,
  fee,
  invalid_before::INTEGER,
  invalid_hereafter::INTEGER,
  valid_contract,
  block_no,
  block.hash,
  slot_no::INTEGER
FROM tx
JOIN block ON tx.block_id = block.id
WHERE tx.id = ANY($1)
ORDER BY tx.id ASC`;

  const result = await db.query<TransactionData>({ name: 'tx_data', rowMode: 'array', text, values: [ids] });

  return result.rows;
};

type TransactionInput = [number, Buffer, Cardano.PaymentAddress, number];

const transactionsInput = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_in_id::INTEGER,
  tx.hash,
  address,
  index
FROM tx_in
JOIN tx_out ON tx_out_id = tx_id AND tx_out_index = index
JOIN tx ON tx_id = tx.id
WHERE tx_in_id = ANY($1)
ORDER BY index, tx_in.id`;

  const result = await db.query<TransactionInput>({ name: 'tx_input', rowMode: 'array', text, values: [ids] });

  return result.rows.reduce((res, input) => {
    let entry = res.get(input[0]);

    if (!entry) {
      entry = [];
      res.set(input[0], entry);
    }

    entry.push({
      address: input[2],
      index: input[3],
      txId: input[1].toString('hex') as Cardano.TransactionId
    });

    return res;
  }, new Map<number, Cardano.HydratedTxIn[]>());
};

type TransactionOutputAsset = [number, string, Buffer];

const transactionsOutputAsset = async (ids: number[], db: Pool) => {
  const text = `\
SELECT
  tx_out_id::INTEGER,
  quantity,
  policy || name
FROM ma_tx_out
JOIN multi_asset ON ident = multi_asset.id
WHERE tx_out_id = ANY($1)
ORDER BY ma_tx_out.id`;

  const result = await db.query<TransactionOutputAsset>({ name: 'out_asset', rowMode: 'array', text, values: [ids] });

  return result.rows;
};

type TransactionOutput = [number, number, Cardano.PaymentAddress, string, Buffer, number];

const transactionsOutput = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  id::INTEGER,
  tx_id::INTEGER,
  address,
  value,
  data_hash,
  reference_script_id::INTEGER
FROM tx_out
WHERE tx_id = ANY($1)
ORDER BY index`;

  const { rows } = await db.query<TransactionOutput>({ name: 'tx_output', rowMode: 'array', text, values: [ids] });
  const outAsset = await transactionsOutputAsset(
    rows.map((row) => row[0]),
    db
  );

  return rows
    .map(([id, ...rest]) => {
      const assets = outAsset
        .filter((asset) => id === asset[0])
        .map((asset) => [asset[2].toString('hex') as Cardano.AssetId, BigInt(asset[1])] as const);

      return [...rest, assets.length === 0 ? undefined : new Map(assets)] as const;
    })
    .reduce((res, output) => {
      let entry = res.get(output[0]);

      if (!entry) {
        entry = [];
        res.set(output[0], entry);
      }

      entry.push({
        address: output[1],
        datum: undefined,
        datumHash: output[3]?.toString('hex') as Cardano.DatumHash,
        scriptReference: undefined,
        value: { assets: output[5], coins: BigInt(output[2]) }
      });

      return res;
    }, new Map<number, Cardano.TxOut[]>());
};

type TransactionMetadata = { bytes: Buffer; id: number; key: string };

const transactionsMetadata = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER AS id,
  key,
  bytes
FROM tx_metadata
WHERE tx_id = ANY($1)`;

  const result = await db.query<TransactionMetadata>({ name: 'tx_metadata', text, values: [ids] });
  const intermediate = result.rows.reduce((res, { id, ...rest }) => {
    let entry = res.get(id);

    if (!entry) {
      entry = [];
      res.set(id, entry);
    }

    entry.push(rest);

    return res;
  }, new Map<number, Pick<TransactionMetadata, 'bytes' | 'key'>[]>());

  return new Map([...intermediate.entries()].map((entry) => [entry[0], { blob: mapTxMetadata(entry[1]) }]));
};

type TransactionMint = [number, string, Buffer];

const transactionsMint = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER,
  quantity,
  policy || name
FROM ma_tx_mint
JOIN multi_asset ON ident = multi_asset.id
WHERE tx_id = ANY($1)
ORDER BY ma_tx_mint.id`;

  const result = await db.query<TransactionMint>({ name: 'tx_mint', rowMode: 'array', text, values: [ids] });

  return result.rows.reduce((res, mint) => {
    let entry = res.get(mint[0]);

    if (!entry) {
      entry = new Map<Cardano.AssetId, bigint>();
      res.set(mint[0], entry);
    }

    entry.set(mint[2].toString('hex') as Cardano.AssetId, BigInt(mint[1]));

    return res;
  }, new Map<number, Map<Cardano.AssetId, bigint>>());
};

type TransactionWithdrawals = [number, string, string];

const transactionsWithdrawals = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER,
  amount,
  view
FROM withdrawal
JOIN stake_address ON stake_address.id = addr_id
WHERE tx_id = ANY($1)
ORDER BY withdrawal.id`;

  const result = await db.query<TransactionWithdrawals>({ name: 'tx_with', rowMode: 'array', text, values: [ids] });

  return result.rows.reduce((res, wit) => {
    let entry = res.get(wit[0]);

    if (!entry) {
      entry = [];
      res.set(wit[0], entry);
    }

    entry.push({ quantity: BigInt(wit[1]), stakeAddress: wit[2] as Cardano.RewardAccount });

    return res;
  }, new Map<number, Cardano.Withdrawal[]>());
};

type PoolRegister = [number, number, string, string];

const poolRegister = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  registered_tx_id::INTEGER,
  cert_index,
  CASE WHEN deposit IS NULL THEN '0' ELSE deposit END AS deposit,
  view
FROM pool_update
JOIN pool_hash ON pool_hash.id = hash_id
WHERE registered_tx_id = ANY($1)`;

  const result = await db.query<PoolRegister>({ name: 'pool_register', rowMode: 'array', text, values: [ids] });

  return result.rows.map(
    (cert) =>
      [
        cert[0],
        cert[1],
        {
          __typename: Cardano.CertificateType.PoolRegistration as const,
          deposit: BigInt(cert[2]),
          poolId: cert[3] as Cardano.PoolId,
          poolParameters: null as unknown as Cardano.PoolParameters
        }
      ] as const
  );
};

type PoolRetire = [number, number, number, string];

const poolRetire = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  announced_tx_id::INTEGER,
  cert_index,
  retiring_epoch,
  view
FROM pool_retire
JOIN pool_hash ON pool_hash.id = hash_id
WHERE announced_tx_id = ANY($1)`;

  const result = await db.query<PoolRetire>({ name: 'pool_retire', rowMode: 'array', text, values: [ids] });

  return result.rows.map(
    (cert) =>
      [
        cert[0],
        cert[1],
        {
          __typename: Cardano.CertificateType.PoolRetirement as const,
          epoch: cert[2] as Cardano.EpochNo,
          poolId: cert[3] as Cardano.PoolId
        }
      ] as const
  );
};

type StakeRegistration = [number, number, number, string];

const stakeRegistration = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER,
  cert_index,
  deposit,
  view
FROM stake_registration
JOIN stake_address ON stake_address.id = addr_id
WHERE tx_id = ANY($1)`;

  const result = await db.query<StakeRegistration>({ name: 'stake_reg', rowMode: 'array', text, values: [ids] });

  return result.rows.map(
    (cert) =>
      [
        cert[0],
        cert[1],
        {
          __typename: Cardano.CertificateType.Registration as const,
          deposit: BigInt(cert[2]),
          stakeCredential: {
            hash: Cardano.RewardAccount.toHash(cert[3] as Cardano.RewardAccount) as unknown as Hash28ByteBase16,
            type: Cardano.CredentialType.KeyHash
          }
        }
      ] as const
  );
};

type StakeUnregistration = [number, number, number, string];

const stakeUnregistration = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER,
  cert_index,
  (SELECT sr.deposit FROM stake_registration AS sr
    WHERE sr.addr_id = sd.addr_id AND sr.tx_id < sd.tx_id
    ORDER BY sr.tx_id DESC LIMIT 1
  ) AS deposit,
  view
FROM stake_deregistration AS sd
JOIN stake_address ON stake_address.id = addr_id
WHERE tx_id = ANY($1)`;

  const result = await db.query<StakeUnregistration>({ name: 'stake_unreg', rowMode: 'array', text, values: [ids] });

  return result.rows.map(
    (cert) =>
      [
        cert[0],
        cert[1],
        {
          __typename: Cardano.CertificateType.Unregistration as const,
          deposit: BigInt(cert[2]),
          stakeCredential: {
            hash: Cardano.RewardAccount.toHash(cert[3] as Cardano.RewardAccount) as unknown as Hash28ByteBase16,
            type: Cardano.CredentialType.KeyHash
          }
        }
      ] as const
  );
};

type StakeDelegation = [number, number, string, string];

const stakeDelegation = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER,
  cert_index,
  addr.view,
  pool.view
FROM delegation
JOIN pool_hash AS pool ON pool.id = pool_hash_id
JOIN stake_address AS addr ON addr.id = addr_id
WHERE tx_id = ANY($1)`;

  const result = await db.query<StakeDelegation>({ name: 'stake_deleg', rowMode: 'array', text, values: [ids] });

  return result.rows.map(
    (cert) =>
      [
        cert[0],
        cert[1],
        {
          __typename: Cardano.CertificateType.StakeDelegation as const,
          poolId: cert[3] as Cardano.PoolId,
          stakeCredential: {
            hash: Cardano.RewardAccount.toHash(cert[2] as Cardano.RewardAccount) as unknown as Hash28ByteBase16,
            type: Cardano.CredentialType.KeyHash
          }
        }
      ] as const
  );
};

type VoteDelegation = [number, number, boolean, Buffer, string];

const voteDelegation = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER,
  cert_index,
  has_script,
  raw,
  stake_address.view
FROM delegation_vote
JOIN drep_hash ON drep_hash.id = drep_hash_id
JOIN stake_address ON stake_address.id = addr_id
WHERE tx_id = ANY($1)`;

  const result = await db.query<VoteDelegation>({ name: 'vote_deleg', rowMode: 'array', text, values: [ids] });

  return result.rows.map(
    (cert) =>
      [
        cert[0],
        cert[1],
        {
          __typename: Cardano.CertificateType.VoteDelegation as const,
          dRep: {
            hash: cert[3].toString('hex') as Hash28ByteBase16,
            type: Number(cert[2]) ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
          },
          stakeCredential: {
            hash: Cardano.RewardAccount.toHash(cert[4] as Cardano.RewardAccount) as unknown as Hash28ByteBase16,
            type: Cardano.CredentialType.KeyHash
          }
        }
      ] as const
  );
};

type DRepCertificate = [string, number, number, boolean, Buffer, string, Buffer];

const dRepCertificate = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  deposit,
  tx_id::INTEGER,
  cert_index,
  has_script,
  raw,
  url,
  data_hash
FROM drep_registration
JOIN drep_hash ON drep_hash.id = drep_hash_id
LEFT JOIN voting_anchor ON voting_anchor.id = voting_anchor_id
WHERE tx_id = ANY($1)`;

  const result = await db.query<DRepCertificate>({ name: 'drep_cert', rowMode: 'array', text, values: [ids] });

  return result.rows.map(([dep, ...cert]) => {
    const update = dep === null;
    const unreg = !update && dep.startsWith('-');
    const deposit = BigInt(update ? 0 : unreg ? dep.slice(1) : dep);
    const anchor = cert[4] && cert[5] ? mapAnchor(cert[4], cert[5].toString('hex')) : null;

    return [
      cert[0],
      cert[1],
      {
        dRepCredential: {
          hash: cert[3].toString('hex') as Hash28ByteBase16,
          type: cert[2] ? Cardano.CredentialType.ScriptHash : Cardano.CredentialType.KeyHash
        },
        ...(update
          ? { __typename: Cardano.CertificateType.UpdateDelegateRepresentative as const, anchor }
          : unreg
          ? { __typename: Cardano.CertificateType.UnregisterDelegateRepresentative as const, deposit }
          : { __typename: Cardano.CertificateType.RegisterDelegateRepresentative as const, anchor, deposit })
      }
    ] as const;
  });
};

const compound = <
  C1 extends Cardano.HydratedCertificate,
  C2 extends Cardano.HydratedCertificate,
  C3 extends Cardano.HydratedCertificate
>(
  certs1: (readonly [number, number, C1])[],
  certs2: (readonly [number, number, C2])[],
  merge: (c1: C1, c2: C2) => C3
) => {
  const result1: (readonly [number, number, C1])[] = [];
  const result: (readonly [number, number, C3])[] = [];
  const foundIndexes2: number[] = [];

  for (const c1 of certs1) {
    const c2index = certs2.findIndex((c2) => c1[0] === c2[0] && c1[1] === c2[1]);

    if (c2index === -1) result1.push(c1);
    else {
      foundIndexes2.push(c2index);
      result.push([c1[0], c1[1], merge(c1[2], certs2[c2index][2])]);
    }
  }

  const result2 = certs2.filter((_, c2index) => !foundIndexes2.includes(c2index));

  return [result1, result2, result] as const;
};

const transactionsCertificates = async (ids: string[], db: Pool) => {
  // eslint-disable-next-line prefer-const
  let [stakeReg, stakeDeleg, voteDeleg, ...rest] = await Promise.all([
    stakeRegistration(ids, db),
    stakeDelegation(ids, db),
    voteDelegation(ids, db),
    poolRegister(ids, db),
    poolRetire(ids, db),
    stakeUnregistration(ids, db),
    dRepCertificate(ids, db)
  ]);

  let stakeRegDeleg: (readonly [number, number, Cardano.StakeRegistrationDelegationCertificate])[];
  let stakeVoteRegDeleg: (readonly [number, number, Cardano.StakeVoteRegistrationDelegationCertificate])[];
  let stakeVoteDeleg: (readonly [number, number, Cardano.StakeVoteDelegationCertificate])[];
  let voteRegDeleg: (readonly [number, number, Cardano.VoteRegistrationDelegationCertificate])[];

  [stakeDeleg, stakeReg, stakeRegDeleg] = compound(
    stakeDeleg,
    stakeReg,
    ({ poolId }, { deposit, stakeCredential }) => ({
      __typename: Cardano.CertificateType.StakeRegistrationDelegation,
      deposit,
      poolId,
      stakeCredential
    })
  );

  // eslint-disable-next-line prefer-const
  [voteDeleg, stakeRegDeleg, stakeVoteRegDeleg] = compound(
    voteDeleg,
    stakeRegDeleg,
    ({ dRep, stakeCredential }, { poolId, deposit }) => ({
      __typename: Cardano.CertificateType.StakeVoteRegistrationDelegation,
      dRep,
      deposit,
      poolId,
      stakeCredential
    })
  );

  // eslint-disable-next-line prefer-const
  [stakeDeleg, voteDeleg, stakeVoteDeleg] = compound(
    stakeDeleg,
    voteDeleg,
    ({ poolId }, { dRep, stakeCredential }) => ({
      __typename: Cardano.CertificateType.StakeVoteDelegation,
      dRep,
      poolId,
      stakeCredential
    })
  );

  // eslint-disable-next-line prefer-const
  [stakeReg, voteDeleg, voteRegDeleg] = compound(stakeReg, voteDeleg, ({ deposit }, { dRep, stakeCredential }) => ({
    __typename: Cardano.CertificateType.VoteRegistrationDelegation,
    dRep,
    deposit,
    stakeCredential
  }));

  return [stakeReg, stakeDeleg, voteDeleg, ...rest, stakeRegDeleg, stakeVoteRegDeleg, stakeVoteDeleg, voteRegDeleg]
    .flat()
    .reduce((res, cert) => {
      let entry = res.get(cert[0]);

      if (!entry) {
        entry = [];
        res.set(cert[0], entry);
      }

      entry[cert[1]] = cert[2];

      return res;
    }, new Map<number, Cardano.HydratedCertificate[]>());
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type TransactionProposals = [number, string, any, string, Buffer, string, string, string];

const transactionProposals = async (ids: string[], db: Pool) => {
  const text = `\
SELECT
  tx_id::INTEGER,
  deposit,
  description,
  url,
  data_hash,
  view,
  quorum_numerator,
  quorum_denominator
FROM gov_action_proposal
JOIN voting_anchor ON voting_anchor_id = voting_anchor.id
JOIN stake_address ON return_address = stake_address.id
LEFT JOIN new_committee ON gov_action_proposal_id = gov_action_proposal.id
WHERE tx_id = ANY($1)
ORDER BY index`;

  const result = await db.query<TransactionProposals>({ name: 'tx_pro', rowMode: 'array', text, values: [ids] });

  return result.rows.reduce((res, proposal) => {
    let entry = res.get(proposal[0]);

    if (!entry) {
      entry = [];
      res.set(proposal[0], entry);
    }

    const { tag } = proposal[2];

    if (!tag) throw new Error('Missing "tag" in governance action proposal description');
    if (typeof tag !== 'string') throw new Error('Wrong "tag" type in governance action proposal description');

    entry.push({
      anchor: mapAnchor(proposal[3], proposal[4].toString('hex'))!,
      deposit: BigInt(proposal[1]),
      governanceAction: getGovernanceAction({
        denominator: proposal[7],
        description: proposal[2],
        numerator: proposal[6],
        type: tag
      }),
      rewardAccount: proposal[5] as Cardano.RewardAccount
    });

    return res;
  }, new Map<number, Cardano.ProposalProcedure[]>());
};

const transactionsByIds = async (ids: string[], db: Pool): Promise<Cardano.HydratedTx[]> => {
  const [txData, input, output, mint, meta, cert, wit, prop] = await Promise.all([
    transactionsData(ids, db),
    transactionsInput(ids, db),
    transactionsOutput(ids, db),
    transactionsMint(ids, db),
    transactionsMetadata(ids, db),
    transactionsCertificates(ids, db),
    transactionsWithdrawals(ids, db),
    transactionProposals(ids, db)
  ]);

  return txData.map((data) => {
    // eslint-disable-next-line unicorn/no-unreadable-array-destructuring
    const [txId, , , , , invalid_before, invalid_hereafter] = data;
    const fee = BigInt(data[4]);
    const inputSource = data[7] ? Cardano.InputSource.inputs : Cardano.InputSource.collaterals;
    const invalidBefore = invalid_before === null ? undefined : invalid_before;
    const invalidHereafter = invalid_hereafter === null ? undefined : invalid_hereafter;

    return {
      auxiliaryData: meta.get(txId),
      blockHeader: { blockNo: data[8], hash: data[9].toString('hex') as Cardano.BlockId, slot: data[10] },
      body: {
        certificates: cert.get(txId),
        collateralReturn: undefined,
        collaterals: [],
        fee,
        inputs: input.get(txId) || [],
        mint: mint.get(txId),
        outputs: output.get(txId) || [],
        proposalProcedures: prop.get(txId),
        validityInterval: { invalidBefore, invalidHereafter },
        votingProcedures: undefined,
        withdrawals: wit.get(txId)
      } as Cardano.HydratedTxBody,
      id: data[1].toString('hex'),
      index: data[2],
      inputSource,
      txSize: data[3],
      witness: { redeemers: undefined, signatures: new Map() }
    } as Cardano.HydratedTx;
  });
};

export const transactionsByAddresses = async (addresses: Cardano.PaymentAddress[], db: Pool, blockId?: string) => {
  const [join, name, values] =
    blockId === undefined
      ? ['', 'tx_id', [addresses]]
      : ['JOIN tx ON tx_id = tx.id AND block_no = $2\n', 'block_tx_id', [addresses, blockId]];

  const text = `\
WITH source AS (
  SELECT tx_id, tx_in_id FROM tx_out
  LEFT JOIN tx_in ON tx_out_id = tx_id AND tx_out_index = index
  ${join}WHERE address = ANY($1)),
combined AS (
  SELECT tx_id FROM source
  UNION ALL
  SELECT tx_in_id AS tx_id FROM source WHERE tx_in_id IS NOT NULL
) SELECT DISTINCT tx_id FROM combined`;

  const result = await db.query<[string]>({ name, rowMode: 'array', text, values });

  return await transactionsByIds(result.rows.flat(), db);
};
