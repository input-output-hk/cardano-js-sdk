/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, Bip32Account, InMemoryKeyAgent, KeyPurpose, util } from '@cardano-sdk/key-management';
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import {
  DatumResolver,
  GenericTxBuilder,
  OutputValidation,
  ResolveDatum,
  RewardAccountWithPoolId,
  TxBuilderProviders
} from '../../src';
import { HexBlob } from '@cardano-sdk/util';
import { dummyLogger } from 'ts-log';
import { mockTxEvaluator } from './mocks';
import { mockProviders as mocks } from '@cardano-sdk/util-dev';
import { roundRobinRandomImprove } from '@cardano-sdk/input-selection';
import uniqBy from 'lodash/uniqBy';

jest.mock('@cardano-sdk/input-selection', () => {
  const actual = jest.requireActual('@cardano-sdk/input-selection');
  return {
    ...actual,
    GreedyInputSelector: jest.fn((args) => new actual.GreedyInputSelector(args)),
    roundRobinRandomImprove: jest.fn((args) => actual.roundRobinRandomImprove(args))
  };
});

const script: Cardano.PlutusScript = {
  __type: Cardano.ScriptType.Plutus,
  bytes: HexBlob(
    '59079201000033232323232323232323232323232332232323232323232222232325335333006300800530070043333573466E1CD55CEA80124000466442466002006004646464646464646464646464646666AE68CDC39AAB9D500C480008CCCCCCCCCCCC88888888888848CCCCCCCCCCCC00403403002C02802402001C01801401000C008CD4060064D5D0A80619A80C00C9ABA1500B33501801A35742A014666AA038EB9406CD5D0A804999AA80E3AE501B35742A01066A0300466AE85401CCCD54070091D69ABA150063232323333573466E1CD55CEA801240004664424660020060046464646666AE68CDC39AAB9D5002480008CC8848CC00400C008CD40B9D69ABA15002302F357426AE8940088C98C80C8CD5CE01981901809AAB9E5001137540026AE854008C8C8C8CCCD5CD19B8735573AA004900011991091980080180119A8173AD35742A004605E6AE84D5D1280111931901919AB9C033032030135573CA00226EA8004D5D09ABA2500223263202E33573805E05C05826AAE7940044DD50009ABA1500533501875C6AE854010CCD540700808004D5D0A801999AA80E3AE200135742A00460446AE84D5D1280111931901519AB9C02B02A028135744A00226AE8940044D5D1280089ABA25001135744A00226AE8940044D5D1280089ABA25001135744A00226AE8940044D55CF280089BAA00135742A00460246AE84D5D1280111931900E19AB9C01D01C01A101B13263201B3357389201035054350001B135573CA00226EA80054049404448C88C008DD6000990009AA80A911999AAB9F0012500A233500930043574200460066AE880080548C8C8CCCD5CD19B8735573AA004900011991091980080180118061ABA150023005357426AE8940088C98C8054CD5CE00B00A80989AAB9E5001137540024646464646666AE68CDC39AAB9D5004480008CCCC888848CCCC00401401000C008C8C8C8CCCD5CD19B8735573AA0049000119910919800801801180A9ABA1500233500F014357426AE8940088C98C8068CD5CE00D80D00C09AAB9E5001137540026AE854010CCD54021D728039ABA150033232323333573466E1D4005200423212223002004357426AAE79400C8CCCD5CD19B875002480088C84888C004010DD71ABA135573CA00846666AE68CDC3A801A400042444006464C6403866AE700740700680640604D55CEA80089BAA00135742A00466A016EB8D5D09ABA2500223263201633573802E02C02826AE8940044D5D1280089AAB9E500113754002266AA002EB9D6889119118011BAB00132001355012223233335573E0044A010466A00E66442466002006004600C6AAE754008C014D55CF280118021ABA200301313574200222440042442446600200800624464646666AE68CDC3A800A40004642446004006600A6AE84D55CF280191999AB9A3370EA0049001109100091931900899AB9C01201100F00E135573AA00226EA80048C8C8CCCD5CD19B875001480188C848888C010014C01CD5D09AAB9E500323333573466E1D400920042321222230020053009357426AAE7940108CCCD5CD19B875003480088C848888C004014C01CD5D09AAB9E500523333573466E1D40112000232122223003005375C6AE84D55CF280311931900899AB9C01201100F00E00D00C135573AA00226EA80048C8C8CCCD5CD19B8735573AA004900011991091980080180118029ABA15002375A6AE84D5D1280111931900699AB9C00E00D00B135573CA00226EA80048C8CCCD5CD19B8735573AA002900011BAE357426AAE7940088C98C802CCD5CE00600580489BAA001232323232323333573466E1D4005200C21222222200323333573466E1D4009200A21222222200423333573466E1D400D2008233221222222233001009008375C6AE854014DD69ABA135744A00A46666AE68CDC3A8022400C4664424444444660040120106EB8D5D0A8039BAE357426AE89401C8CCCD5CD19B875005480108CC8848888888CC018024020C030D5D0A8049BAE357426AE8940248CCCD5CD19B875006480088C848888888C01C020C034D5D09AAB9E500B23333573466E1D401D2000232122222223005008300E357426AAE7940308C98C8050CD5CE00A80A00900880800780700680609AAB9D5004135573CA00626AAE7940084D55CF280089BAA0012323232323333573466E1D400520022333222122333001005004003375A6AE854010DD69ABA15003375A6AE84D5D1280191999AB9A3370EA0049000119091180100198041ABA135573CA00C464C6401A66AE7003803402C0284D55CEA80189ABA25001135573CA00226EA80048C8C8CCCD5CD19B875001480088C8488C00400CDD71ABA135573CA00646666AE68CDC3A8012400046424460040066EB8D5D09AAB9E500423263200A33573801601401000E26AAE7540044DD500089119191999AB9A3370EA00290021091100091999AB9A3370EA00490011190911180180218031ABA135573CA00846666AE68CDC3A801A400042444004464C6401666AE7003002C02402001C4D55CEA80089BAA0012323333573466E1D40052002212200223333573466E1D40092000212200123263200733573801000E00A00826AAE74DD5000891999AB9A3370E6AAE74DD5000A40004008464C6400866AE700140100092612001490103505431001123230010012233003300200200122212200201'
  ),
  version: Cardano.PlutusLanguageVersion.V2
};

export const foreignUtxo: Cardano.Utxo[] = [
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
      ),
      index: 99,
      txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
      ),
      value: {
        coins: 4_027_026_465n
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
      ),
      index: 100,
      txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
      ),
      datum: 1n,
      value: {
        coins: 4_027_026_465n
      }
    }
  ],
  [
    {
      address: Cardano.PaymentAddress(
        'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
      ),
      index: 200,
      txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    },
    {
      address: Cardano.PaymentAddress(
        'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
      ),
      scriptReference: script,
      value: {
        coins: 4_027_026_465n
      }
    }
  ]
];

const inputResolver: Cardano.InputResolver = {
  resolveInput: async (txIn) =>
    mocks.utxo.find(([hydratedTxIn]) => txIn.txId === hydratedTxIn.txId && txIn.index === hydratedTxIn.index)?.[1] ||
    foreignUtxo.find(([hydratedTxIn]) => txIn.txId === hydratedTxIn.txId && txIn.index === hydratedTxIn.index)?.[1] ||
    null
};

/** Utility factory for tests to create a GenericTxBuilder with mocked dependencies */
const createTxBuilder = async ({
  stakeDelegations,
  numAddresses = stakeDelegations.length,
  useMultiplePaymentKeys = false,
  rewardAccounts,
  keyAgent,
  datumResolver
}: {
  stakeDelegations: {
    credentialStatus: Cardano.StakeCredentialStatus;
    poolId?: Cardano.PoolId;
    deposit?: Cardano.Lovelace;
  }[];
  numAddresses?: number;
  useMultiplePaymentKeys?: boolean;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  rewardAccounts?: any;
  keyAgent: InMemoryKeyAgent;
  datumResolver?: DatumResolver;
}) => {
  let groupedAddresses = await Promise.all(
    Array.from({ length: numAddresses }).map(async (_, idx) =>
      keyAgent.deriveAddress({ index: 0, type: AddressType.External }, idx)
    )
  );

  // Simulate an HD wallet where a each stake key partitions 2 payment keys (2 addresses per stake key)
  if (useMultiplePaymentKeys) {
    const groupedAddresses2 = await Promise.all(
      stakeDelegations.map(async (_, idx) => keyAgent.deriveAddress({ index: 1, type: AddressType.External }, idx))
    );
    groupedAddresses = [...groupedAddresses, ...groupedAddresses2];
  }

  const txBuilderProviders: jest.Mocked<TxBuilderProviders> = {
    addresses: {
      add: jest.fn().mockImplementation((...addreses) => groupedAddresses.push(...addreses)),
      get: jest.fn().mockResolvedValue(groupedAddresses)
    },
    genesisParameters: jest.fn().mockResolvedValue(mocks.genesisParameters),
    protocolParameters: jest.fn().mockResolvedValue(mocks.protocolParameters),
    rewardAccounts:
      rewardAccounts ||
      jest.fn().mockImplementation(() =>
        Promise.resolve(
          // There can be multiple addresses with the same reward account. Extract the uniq reward accounts
          uniqBy(groupedAddresses, ({ rewardAccount }) => rewardAccount)
            // Create mock stakeKey/delegation status for each reward account according to the requested stakeDelegations.
            // This would normally be done by the wallet.delegation.rewardAccounts
            .map<RewardAccountWithPoolId>(({ rewardAccount: address }, index) => {
              const { credentialStatus, poolId, deposit } = stakeDelegations[index] ?? {};
              return {
                address,
                credentialStatus: credentialStatus ?? Cardano.StakeCredentialStatus.Unregistered,
                rewardBalance: mocks.rewardAccountBalance,
                ...(poolId ? { delegatee: { nextNextEpoch: { id: poolId } } } : undefined),
                ...(deposit && { deposit })
              };
            })
        )
      ),
    tip: jest.fn().mockResolvedValue(mocks.ledgerTip),
    utxoAvailable: jest.fn().mockResolvedValue(mocks.utxo)
  };
  const outputValidator = {
    validateOutput: jest.fn().mockResolvedValue({ coinMissing: 0n } as OutputValidation)
  };
  const asyncKeyAgent = util.createAsyncKeyAgent(keyAgent);
  return {
    groupedAddresses,
    txBuilder: new GenericTxBuilder({
      bip32Account: await Bip32Account.fromAsyncKeyAgent(asyncKeyAgent),
      datumResolver,
      inputResolver,
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders,
      txEvaluator: mockTxEvaluator,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    }),
    txBuilderProviders,
    txBuilderWithoutBip32Account: new GenericTxBuilder({
      inputResolver,
      logger: dummyLogger,
      outputValidator,
      txBuilderProviders,
      txEvaluator: mockTxEvaluator,
      witnesser: util.createBip32Ed25519Witnesser(asyncKeyAgent)
    })
  };
};

describe('TxBuilder/plutusScripts', () => {
  let txBuilder: GenericTxBuilder;
  let keyAgent: InMemoryKeyAgent;

  beforeEach(async () => {
    keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
      {
        chainId: Cardano.ChainIds.Preprod,
        getPassphrase: async () => Buffer.from('passphrase'),
        mnemonicWords: util.generateMnemonicWords(),
        purpose: KeyPurpose.STANDARD
      },
      { bip32Ed25519: new Crypto.SodiumBip32Ed25519(), logger: dummyLogger }
    );

    const txBuilderFactory = await createTxBuilder({
      keyAgent,
      stakeDelegations: [{ credentialStatus: Cardano.StakeCredentialStatus.Unregistered }]
    });
    txBuilder = txBuilderFactory.txBuilder;
  });

  afterEach(() => jest.clearAllMocks());

  it('can set an unresolved input for required selection', async () => {
    const tx = await txBuilder
      .addInput({
        index: 99,
        txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
      })
      .build()
      .inspect();

    expect(
      tx.body.inputs?.some((txIn) => txIn.txId === 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    ).toBeTruthy();
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('can set a resolved input for required selection', async () => {
    const tx = await txBuilder
      .addInput([
        {
          address: Cardano.PaymentAddress(
            'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
          ),
          index: 2,
          txId: Cardano.TransactionId('0021ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ff00')
        },
        {
          address: Cardano.PaymentAddress(
            'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
          ),
          value: {
            coins: 4_000_000n
          }
        }
      ])
      .build()
      .inspect();

    expect(
      tx.body.inputs?.some((txIn) => txIn.txId === '0021ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ff00')
    ).toBeTruthy();
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('can set an script input for required selection', async () => {
    const tx = await txBuilder
      .addInput(
        {
          index: 99,
          txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
        },
        {
          datum: 1n,
          redeemer: 1n,
          script
        }
      )
      .build()
      .inspect();

    expect(
      tx.body.inputs?.some((txIn) => txIn.txId === 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    ).toBeTruthy();
    expect(tx.witness?.datums?.some((datum) => datum === 1n)).toBeTruthy();
    expect(tx.witness?.redeemers?.some((redeemer) => redeemer.data === 1n)).toBeTruthy();
    expect(tx.witness?.scripts?.some((s) => s === script)).toBeTruthy();
    expect(tx.body.scriptIntegrityHash).toEqual('6f33e6b98194924c306d686a35ed5560eb25be58fc72b721a50fc895a7d3f304');
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('can point the redeemer to the right input', async () => {
    const tx = await txBuilder
      .addInput(
        {
          index: 99,
          txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
        },
        {
          datum: 1n,
          redeemer: 1n,
          script
        }
      )
      .addOutput(
        txBuilder
          .buildOutput({
            address: Cardano.PaymentAddress(
              'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
            ),
            value: { coins: 5_000_000_000n }
          })
          .toTxOut()
      )
      .build()
      .inspect();

    expect(
      tx.body.inputs?.some((txIn) => txIn.txId === 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    ).toBeTruthy();
    expect(tx.witness?.redeemers?.some((redeemer) => redeemer.data === 1n)).toBeTruthy();

    const scriptInputIndex = tx.body.inputs?.findIndex(
      (input) => input.txId === 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' && input.index === 99
    );
    expect(tx.witness?.redeemers?.at(0)?.index).toEqual(scriptInputIndex);
  });

  it('can set an script input for required selection with inline datum (unresolved),', async () => {
    const tx = await txBuilder
      .addInput(
        {
          index: 100, // Resolves to an input with inline datum
          txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
        },
        {
          redeemer: 1n,
          script
        }
      )
      .build()
      .inspect();

    expect(
      tx.body.inputs?.some((txIn) => txIn.txId === 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    ).toBeTruthy();
    expect(tx.witness?.datums).toEqual([]);
    expect(tx.witness?.redeemers?.some((redeemer) => redeemer.data === 1n)).toBeTruthy();
    expect(tx.witness?.scripts?.some((s) => s === script)).toBeTruthy();
    expect(tx.body.scriptIntegrityHash).toEqual('8b80faf1027b026031a75f38e8fd8b23bdf7abab3455b9cf57f3b4851205af03');
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('can set an script input for required selection with inline datum (resolved),', async () => {
    const utxo = [
      {
        address: Cardano.PaymentAddress(
          'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
        ),
        index: 100,
        txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
      },
      {
        address: Cardano.PaymentAddress(
          'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
        ),
        datum: 1n,
        value: {
          coins: 4_027_026_465n
        }
      }
    ] as Cardano.Utxo;

    const tx = await txBuilder
      .addInput(utxo, {
        redeemer: 1n,
        script
      })
      .build()
      .inspect();

    expect(
      tx.body.inputs?.some((txIn) => txIn.txId === 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    ).toBeTruthy();
    expect(tx.witness?.datums).toEqual([]);
    expect(tx.witness?.redeemers?.some((redeemer) => redeemer.data === 1n)).toBeTruthy();
    expect(tx.witness?.scripts?.some((s) => s === script)).toBeTruthy();
    expect(tx.body.scriptIntegrityHash).toEqual('8b80faf1027b026031a75f38e8fd8b23bdf7abab3455b9cf57f3b4851205af03');
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('can set an script input for required selection with reference script', async () => {
    const tx = await txBuilder
      .addReferenceInput({
        index: 200,
        txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
      })
      .addInput(
        {
          index: 99,
          txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
        },
        {
          datum: 1n,
          redeemer: 1n
        }
      )
      .build()
      .inspect();

    expect(
      tx.body.inputs?.some((txIn) => txIn.txId === 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
    ).toBeTruthy();
    expect(tx.witness?.datums?.some((datum) => datum === 1n)).toBeTruthy();
    expect(tx.witness?.redeemers?.some((redeemer) => redeemer.data === 1n)).toBeTruthy();
    expect(tx.witness?.scripts).toEqual([]);
    expect(tx.body.scriptIntegrityHash).toEqual('6f33e6b98194924c306d686a35ed5560eb25be58fc72b721a50fc895a7d3f304');
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('can resolve datums via datumResolver', async () => {
    const mockResolveDatum: ResolveDatum = jest.fn().mockImplementation(() => Promise.resolve(1n));

    const mockDatumResolver: DatumResolver = {
      resolve: mockResolveDatum
    };

    const customBuilder = (
      await createTxBuilder({
        datumResolver: mockDatumResolver,
        keyAgent,
        stakeDelegations: [{ credentialStatus: Cardano.StakeCredentialStatus.Unregistered }]
      })
    ).txBuilder;

    const tx = await customBuilder
      .addReferenceInput({
        index: 200,
        txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
      })
      .addInput(
        [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
            ),
            index: 100,
            txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
          },
          {
            address: Cardano.PaymentAddress(
              'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
            ),
            datumHash: 'some hash' as Cardano.DatumHash,
            value: {
              coins: 4_027_026_465n
            }
          }
        ],
        {
          redeemer: 1n
        }
      )
      .build()
      .inspect();

    expect(tx.witness?.datums?.some((datum) => datum === 1n)).toBeTruthy();
    expect(tx.witness?.redeemers?.some((redeemer) => redeemer.data === 1n)).toBeTruthy();
    expect(tx.witness?.scripts).toEqual([]);
    expect(tx.body.scriptIntegrityHash).toEqual('6f33e6b98194924c306d686a35ed5560eb25be58fc72b721a50fc895a7d3f304');
    expect(mockDatumResolver.resolve).toHaveBeenCalledWith('some hash');
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('can resolve datums if provided via addDatum method', async () => {
    const tx = await txBuilder
      .addReferenceInput({
        index: 200,
        txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
      })
      .addInput(
        [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
            ),
            index: 100,
            txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
          },
          {
            address: Cardano.PaymentAddress(
              'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
            ),
            datumHash: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25' as Cardano.DatumHash,
            value: {
              coins: 4_027_026_465n
            }
          }
        ],
        {
          redeemer: 1n
        }
      )
      .addDatum(1n)
      .build()
      .inspect();

    expect(tx.witness?.datums?.some((datum) => datum === 1n)).toBeTruthy();
    expect(tx.witness?.redeemers?.some((redeemer) => redeemer.data === 1n)).toBeTruthy();
    expect(tx.witness?.scripts).toEqual([]);
    expect(tx.body.scriptIntegrityHash).toEqual('6f33e6b98194924c306d686a35ed5560eb25be58fc72b721a50fc895a7d3f304');
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('set collaterals and return collateral automatically', async () => {
    const tx = await txBuilder
      .addReferenceInput({
        index: 200,
        txId: 'ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0' as unknown as Cardano.TransactionId
      })
      .addInput(
        [
          {
            address: Cardano.PaymentAddress(
              'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
            ),
            index: 100,
            txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
          },
          {
            address: Cardano.PaymentAddress(
              'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
            ),
            datumHash: 'ee155ace9c40292074cb6aff8c9ccdd273c81648ff1149ef36bcea6ebb8a3e25' as Cardano.DatumHash,
            value: {
              coins: 4_027_026_465n
            }
          }
        ],
        {
          redeemer: 1n
        }
      )
      .addDatum(1n)
      .build()
      .inspect();

    expect(tx.body.collaterals).toBeDefined();
    expect(tx.body.collateralReturn).toBeDefined();

    const values: Array<Cardano.Value> = (
      await Promise.all(tx.body.collaterals!.map((input) => inputResolver.resolveInput(input)))
    )
      .filter((x) => x !== null)
      .map((out) => out!.value);

    const totalCollateralValue = coalesceValueQuantities(values);

    expect(totalCollateralValue.coins - tx.body.collateralReturn!.value.coins).toEqual(5_000_000n);
    expect(totalCollateralValue.assets).toEqual(tx.body.collateralReturn!.value.assets);
    expect(roundRobinRandomImprove).toHaveBeenCalled();
  });

  it('throws when given an input that cant be resolved', async () => {
    await expect(
      txBuilder
        .addInput({
          index: 0,
          txId: 'A' as unknown as Cardano.TransactionId
        })
        .build()
        .inspect()
    ).rejects.toThrow('Could not resolve input A#0');
  });

  it('throws when given an script input with datumHash, datum is not provided and datumResolver is not set', async () => {
    await expect(
      txBuilder
        .addInput(
          [
            {
              address: Cardano.PaymentAddress(
                'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
              ),
              index: 100,
              txId: Cardano.TransactionId('ff21ffbaff60ff0cff8cff55ffa6ff6dff78ff78ffaeffceff36ff3fffc5ffe0')
            },
            {
              address: Cardano.PaymentAddress(
                'addr_test1qqt9c69kjqf0wsnlp7hs8xees5l6pm4yxdqa3hknqr0kfe0htmj4e5t8n885zxm4qzpfzwruqx3ey3f5q8kpkr0gt9ms8dcsz6'
              ),
              datumHash: 'some hash' as Cardano.DatumHash,
              value: {
                coins: 4_027_026_465n
              }
            }
          ],
          {
            redeemer: 1n
          }
        )
        .build()
        .inspect()
    ).rejects.toThrow('Cant resolve unknown datums. Datum resolver not set.');
  });
});
