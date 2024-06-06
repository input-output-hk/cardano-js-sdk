import { Cardano } from '@cardano-sdk/core';
import { GreedyTxEvaluator } from '../../src/index.js';

const getParams = (): Promise<Cardano.ProtocolParameters> =>
  Promise.resolve({
    maxExecutionUnitsPerTransaction: {
      memory: 100,
      steps: 200
    }
  } as unknown as Cardano.ProtocolParameters);

const tx = {
  witness: {
    redeemers: [
      {
        data: 1n,
        executionUnits: {
          memory: 0,
          steps: 0
        },
        index: 0,
        purpose: Cardano.RedeemerPurpose.spend
      }
    ]
  }
} as unknown as Cardano.Tx;

describe('GreedyTxEvaluator', () => {
  it('assigns maxExecutionUnitsPerTransaction to the redeemer', async () => {
    // Arrange
    const evaluator = new GreedyTxEvaluator(getParams);

    // Act
    const result = await evaluator.evaluate(tx, []);

    // Assert
    expect(result).toEqual([
      {
        budget: {
          memory: 100,
          steps: 200
        },
        index: 0,
        purpose: Cardano.RedeemerPurpose.spend
      }
    ]);
  });
});
