import { Cardano, DRepInfo } from '@cardano-sdk/core';
import { createTestScheduler } from '@cardano-sdk/util-dev';
import { drepsToDelegatees, drepsToDrepIds, onlyDistinctBlockRefetch } from '../../src/services/DrepInfoTracker';

// From preview.gov.tools/drep_directory
const DREP_IDS = [
  'drep1xaaduszgcqptvzhtt4mrgsjp8h9tc0d0pccma39ns6uh2elk56u',
  'drep1y93l7d0f3sy3y3asse3t48uewsum96t4s8rel99m65t3u89tzy0',
  'drep1epa4q3az62nw8pj4jnqcd4cjeen3pxattjkhh2uu8zjtsg2j6h0'
];

describe('drepInfoTracker', () => {
  let drepIds: Cardano.DRepID[];
  beforeEach(() => {
    drepIds = DREP_IDS.map(Cardano.DRepID).map(Cardano.DRepID.toCip129DRepID);
  });

  describe('drepsToDelegatees', () => {
    it('replace dreps with drepInfos, without changing undefined, AlwaysAbstain and AlwaysNoConfidence', () => {
      const dreps: (Cardano.DelegateRepresentative | undefined)[] = [
        { __typename: 'AlwaysAbstain' },
        Cardano.DRepID.toCredential(drepIds[0]),
        undefined,
        Cardano.DRepID.toCredential(drepIds[1]),
        { __typename: 'AlwaysNoConfidence' },
        Cardano.DRepID.toCredential(drepIds[2])
      ];

      const drepInfos: DRepInfo[] = [
        { active: true, amount: 0n, hasScript: false, id: drepIds[0] },
        { active: false, amount: 0n, hasScript: false, id: drepIds[1] },
        { active: true, amount: 0n, hasScript: false, id: drepIds[2] }
      ];

      expect(drepsToDelegatees(dreps)(drepInfos)).toEqual([
        { delegateRepresentative: { __typename: 'AlwaysAbstain' } },
        { delegateRepresentative: drepInfos[0] },
        undefined,
        { delegateRepresentative: drepInfos[1] },
        { delegateRepresentative: { __typename: 'AlwaysNoConfidence' } },
        { delegateRepresentative: drepInfos[2] }
      ]);
    });

    it('should replace not found drepId with undefined', () => {
      const dreps: (Cardano.DelegateRepresentative | undefined)[] = [
        Cardano.DRepID.toCredential(drepIds[0]),
        Cardano.DRepID.toCredential(drepIds[1])
      ];

      const drepInfos: DRepInfo[] = [{ active: true, amount: 0n, hasScript: false, id: drepIds[1] }];

      expect(drepsToDelegatees(dreps)(drepInfos)).toEqual([undefined, { delegateRepresentative: drepInfos[0] }]);
    });
  });

  describe('drepsToDrepIds', () => {
    it('should remove duplicates and map to DRepID[]', () => {
      const dreps: (Cardano.DelegateRepresentative | undefined)[] = [
        Cardano.DRepID.toCredential(drepIds[0]),
        Cardano.DRepID.toCredential(drepIds[1]),
        Cardano.DRepID.toCredential(drepIds[0])
      ];

      expect(drepsToDrepIds(dreps)).toEqual([drepIds[0], drepIds[1]]);
    });

    it('should remove undefined, AlwaysAbstain and AlwaysNoConfidence', () => {
      const dreps: (Cardano.DelegateRepresentative | undefined)[] = [
        { __typename: 'AlwaysAbstain' },
        Cardano.DRepID.toCredential(drepIds[0]),
        undefined,
        { __typename: 'AlwaysNoConfidence' },
        Cardano.DRepID.toCredential(drepIds[1])
      ];

      expect(drepsToDrepIds(dreps)).toEqual([drepIds[0], drepIds[1]]);
    });
  });

  describe('onlyDistinctBlockRefetch', () => {
    it('should ignore refetch while on the same block', () => {
      createTestScheduler().run(({ cold, expectObservable }) => {
        const refetchTrigger$ = cold('aaa', { a: void 0 });
        const tip$ = cold('           a-b', { a: { blockNo: Cardano.BlockNo(1) }, b: { blockNo: Cardano.BlockNo(2) } });

        expectObservable(onlyDistinctBlockRefetch(refetchTrigger$, tip$)).toBe('a-a', { a: void 0 });
      });
    });
  });
});
