import { InvalidArgumentError } from '@cardano-sdk/util';
import { PlutusLanguageVersion } from '../../../Cardano/types/Script';

/**
 * The execution of plutus scripts consumes resources. To make sure that these
 * scripts don't run indefinitely or consume excessive resources (which would be
 * harmful to the network), Cardano introduces the concept of "cost models".
 *
 * Cost models are in place to provide predictable pricing for script execution.
 *
 * It's a way to gauge how much resource (in terms of computational steps or memory)
 * a script would use.
 */
export class CostModel {
  #language: PlutusLanguageVersion;
  #costs: Array<number>;

  /**
   * Initializes a new instance of the CostModel class.
   *
   * @param language The plutus language version.
   * @param costs The costs.
   */
  constructor(language: PlutusLanguageVersion, costs: Array<number>) {
    this.#language = language;
    this.#costs = costs;
  }

  /**
   * Creates a new Plutus V1 cost model.
   *
   * @param costs An array containing the costs for all operations.
   */
  static newPlutusV1(costs: Array<number>): CostModel {
    return new CostModel(PlutusLanguageVersion.V1, costs);
  }

  /**
   * Creates a new Plutus V2 cost model.
   *
   * @param costs An array containing the costs for all operations.
   */
  static newPlutusV2(costs: Array<number>): CostModel {
    return new CostModel(PlutusLanguageVersion.V2, costs);
  }

  /**
   * Creates a new Plutus V3 cost model.
   *
   * @param costs An array containing the costs for all operations.
   */
  static newPlutusV3(costs: Array<number>): CostModel {
    return new CostModel(PlutusLanguageVersion.V3, costs);
  }

  /**
   * Sets the cost for the given operation.
   *
   * @param operation The operation to get the cost for.
   * @param cost The cost of the operation.
   */
  set(operation: number, cost: number): void {
    if (!this.#isOperationValid(operation))
      throw new InvalidArgumentError(
        'operation',
        `The given operation ${operation} is invalid for the current Language version ${this.#language}.`
      );

    this.#costs[operation] = cost;
  }

  /**
   * Gets the cost for the given operation.
   *
   * @param operation The operation to get the cost for.
   * @returns The operation cost.
   */
  get(operation: number): number {
    if (!this.#isOperationValid(operation))
      throw new InvalidArgumentError(
        'operation',
        `The given operation ${operation} is invalid for the current Language version ${this.#language}.`
      );

    return this.#costs[operation];
  }

  /**
   * Gets the list of costs as a int array.
   *
   * @returns The list of costs, where the index on the array represents the operation id and the value
   * the operation cost.
   */
  costs(): Array<number> {
    return this.#costs;
  }

  /**
   * Gets the language version of this cost model.
   *
   * @returns The language version.
   */
  language(): PlutusLanguageVersion {
    return this.#language;
  }

  /**
   * Gets whether the given operation is valid for this Language version.
   *
   * @param operation The operation we are trying to validate.
   * @returns true if is a valid operation; otherwise; false.
   */
  #isOperationValid(operation: number): boolean {
    return operation >= 0;
  }
}
