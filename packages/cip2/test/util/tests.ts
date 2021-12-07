import { Cardano } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../../src/InputSelectionError';
import { InputSelector } from '../../src/types';
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
  createUtxo: () => Cardano.Utxo[];
  /**
   * Transaction outputs
   */
  createOutputs: () => Cardano.TxOut[];
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
    algorithm.select({ constraints: SelectionConstraints.mockConstraintsToConstraints(mockConstraints), outputs, utxo })
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
    constraints: SelectionConstraints.mockConstraintsToConstraints(mockConstraints),
    outputs,
    utxo
  });
  assertInputSelectionProperties({ constraints: mockConstraints, outputs, results, utxo });
};
