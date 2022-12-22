import { KeyAgentDependencies } from '../../src/';
import { dummyLogger } from 'ts-log';

export const mockKeyAgentDependencies = (): jest.Mocked<KeyAgentDependencies> => ({
  inputResolver: {
    resolveInputAddress: jest.fn().mockResolvedValue(null)
  },
  logger: dummyLogger
});
