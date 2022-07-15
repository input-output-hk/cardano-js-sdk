import { KeyAgentDependencies } from '../../src/KeyManagement';

export const mockKeyAgentDependencies = (): jest.Mocked<KeyAgentDependencies> => ({
  inputResolver: {
    resolveInputAddress: jest.fn().mockResolvedValue(null)
  }
});
