import { ChainSyncData } from '../../../golden-test-generator/src';
import { ProjectorEvent } from '../../src';
import { from } from 'rxjs';

const prepareData = (dataFileName: string) => {
  const {
    body: events,
    metadata: {
      cardano: { compactGenesis }
    }
  } = require(`./data/${dataFileName}`) as ChainSyncData;
  return {
    chainSync$: from(events as ProjectorEvent[]),
    genesis: compactGenesis
  };
};
export type StubChainSyncData = ReturnType<typeof prepareData>;

export const dataWithPoolRetirement = prepareData('with-pool-retirement.json');
export const dataWithStakeKeyDeregistration = prepareData('with-stake-key-deregistration');
