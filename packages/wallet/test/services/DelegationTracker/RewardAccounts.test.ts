import { InMemoryStakePoolsStore } from '../../../src/persistence';

describe('RewardAccounts', () => {
  // const twoRewardAccounts = [
  //   'stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27',
  //   'stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d'
  // ].map(Cardano.RewardAccount);

  let store: InMemoryStakePoolsStore;

  beforeEach(() => {
    store = new InMemoryStakePoolsStore();
    store.getValues = jest.fn().mockImplementation(store.getValues.bind(store));
  });

  describe('createRewardAccountsTracker', () => {
    it.todo('TODO');
  });
});
