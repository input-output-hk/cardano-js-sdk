/* eslint-disable sonarjs/no-duplicate-string */
import * as Cardano from '../../../../src/Cardano';
import { HexBlob } from '@cardano-sdk/util';
import { ProposalProcedure } from '../../../../src/Serialization';

const infoActionCbor = HexBlob(
  '841a000f4240581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f06827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
);

const infoActionCore = {
  anchor: {
    dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
    url: 'https://www.someurl.io'
  },
  deposit: 1_000_000n,
  governanceAction: {
    __typename: Cardano.GovernanceActionType.info_action
  },
  rewardAccount: 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'
} as Cardano.ProposalProcedure;

const cbor = HexBlob(
  '841a000f4240581de1cb0ec2692497b458e46812c8a5bfa2931d1a2d965a99893828ec810f830582582000000000000000000000000000000000000000000000000000000000000000000382827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000f6827668747470733a2f2f7777772e736f6d6575726c2e696f58200000000000000000000000000000000000000000000000000000000000000000'
);
const core = {
  anchor: {
    dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
    url: 'https://www.someurl.io'
  },
  deposit: 1_000_000n,
  governanceAction: {
    __typename: Cardano.GovernanceActionType.new_constitution,
    constitution: {
      anchor: {
        dataHash: '0000000000000000000000000000000000000000000000000000000000000000',
        url: 'https://www.someurl.io'
      },
      scriptHash: null
    },
    governanceActionId: {
      actionIndex: 3,
      id: '0000000000000000000000000000000000000000000000000000000000000000'
    }
  },
  rewardAccount: 'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'
} as Cardano.ProposalProcedure;

describe('ProposalProcedure', () => {
  it('can encode ProposalProcedure to CBOR', () => {
    const action = ProposalProcedure.fromCore(core);

    expect(action.toCbor()).toEqual(cbor);
  });

  it('can encode ProposalProcedure to Core', () => {
    const action = ProposalProcedure.fromCbor(cbor);

    expect(action.toCore()).toEqual(core);
  });

  it('can encode InfoAction ProposalProcedure to CBOR', () => {
    const action = ProposalProcedure.fromCore(infoActionCore);

    expect(action.toCbor()).toEqual(infoActionCbor);
  });

  it('can encode InfoAction ProposalProcedure to Core', () => {
    const action = ProposalProcedure.fromCbor(infoActionCbor);

    expect(action.toCore()).toEqual(infoActionCore);
  });
});
