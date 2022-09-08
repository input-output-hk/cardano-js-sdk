import { KeyAgentDependencies } from '../../src/';

export const mockKeyAgentDependencies = (): jest.Mocked<KeyAgentDependencies> => ({
  inputResolver: {
    resolveInputAddress: jest.fn().mockResolvedValue(null)
  }
});
