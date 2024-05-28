import * as SelectionConstraints from './selectionConstraints';
import { Cardano } from '@cardano-sdk/core';
import { ImplicitValue, InputSelector } from '../../src/types';
import { InputSelectionError, InputSelectionFailure } from '../../src/InputSelectionError';
import { assertInputSelectionProperties } from './properties';

export interface InputSelectionPropertiesTestParams {
  /** Test subject (Input Selection algorithm under test) */
  getAlgorithm: () => InputSelector;
  /** Outputs that must always be included in the selection */
  createPreSelectedOutputUtxo: () => Cardano.Utxo[];
  /** Available UTxO */
  createUtxo: () => Cardano.Utxo[];
  /** Transaction outputs */
  createOutputs: () => Cardano.TxOut[];
  /** Transaction outputs */
  implicitValue?: ImplicitValue;
  /** Input selection constraints passed to the algorithm. */
  mockConstraints: SelectionConstraints.MockSelectionConstraints;
}

export interface InputSelectionFailureModeTestParams extends InputSelectionPropertiesTestParams {
  /** Error that should be thrown */
  expectedError: InputSelectionFailure;
}

/** Run input selection and assert that implementation throws error of specific failure. */
export const testInputSelectionFailureMode = async ({
  getAlgorithm,
  createUtxo,
  createOutputs,
  implicitValue,
  expectedError,
  mockConstraints
}: InputSelectionFailureModeTestParams) => {
  const preSelectedUtxo = new Set<Cardano.Utxo>();
  const utxo = new Set(createUtxo());
  const outputs = new Set(createOutputs());
  const algorithm = getAlgorithm();
  await expect(
    algorithm.select({
      constraints: SelectionConstraints.mockConstraintsToConstraints(mockConstraints),
      implicitValue,
      outputs,
      preSelectedUtxo,
      utxo
    })
  ).rejects.toThrowError(new InputSelectionError(expectedError));
};

/** Run input selection and assert properties */
export const testInputSelectionProperties = async ({
  getAlgorithm,
  createUtxo,
  createOutputs,
  implicitValue,
  mockConstraints
}: InputSelectionPropertiesTestParams) => {
  const preSelectedUtxo = new Set<Cardano.Utxo>();
  const utxo = new Set(createUtxo());
  const outputs = new Set(createOutputs());
  const algorithm = getAlgorithm();
  const results = await algorithm.select({
    constraints: SelectionConstraints.mockConstraintsToConstraints(mockConstraints),
    implicitValue,
    outputs,
    preSelectedUtxo,
    utxo
  });
  assertInputSelectionProperties({ constraints: mockConstraints, outputs, results, utxo });
};
