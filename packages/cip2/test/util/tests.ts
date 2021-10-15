import { CSL } from '@cardano-sdk/core';
import { InputSelector } from '../../src/types';
import { InputSelectionError, InputSelectionFailure } from '../../src/InputSelectionError';
import { SelectionConstraints } from '@cardano-sdk/util-dev';
import { assertInputSelectionProperties } from './properties';

export interface InputSelectionPropertiesTestParams {
  /**
   * Test subject (Input Selection algorithm under test)
   */
  getAlgorithm: () => InputSelector;
  /**
   * Available UTxO
   */
  createUtxo: () => CSL.TransactionUnspentOutput[];
  /**
   * Transaction outputs
   */
  createOutputs: () => CSL.TransactionOutput[];
  /**
   * Input selection constraints passed to the algorithm.
   */
  mockConstraints: SelectionConstraints.MockSelectionConstraints;
}

export interface InputSelectionFailureModeTestParams extends InputSelectionPropertiesTestParams {
  /**
   * Error that should be thrown
   */
  expectedError: InputSelectionFailure;
}

/**
 * Run input selection and assert that implementation throws error of specific failure.
 */
export const testInputSelectionFailureMode = async ({
  getAlgorithm,
  createUtxo,
  createOutputs,
  expectedError,
  mockConstraints
}: InputSelectionFailureModeTestParams) => {
  const utxo = new Set(createUtxo());
  const outputs = new Set(createOutputs());
  const algorithm = getAlgorithm();
  await expect(
    algorithm.select({ utxo, outputs, constraints: SelectionConstraints.mockConstraintsToConstraints(mockConstraints) })
  ).rejects.toThrowError(new InputSelectionError(expectedError));
};

/**
 * Run input selection and assert properties
 */
export const testInputSelectionProperties = async ({
  getAlgorithm,
  createUtxo,
  createOutputs,
  mockConstraints
}: InputSelectionPropertiesTestParams) => {
  const utxo = new Set(createUtxo());
  const outputs = new Set(createOutputs());
  const algorithm = getAlgorithm();
  const results = await algorithm.select({
    utxo,
    outputs,
    constraints: SelectionConstraints.mockConstraintsToConstraints(mockConstraints)
  });
  assertInputSelectionProperties({ results, outputs, constraints: mockConstraints, utxo });
};
