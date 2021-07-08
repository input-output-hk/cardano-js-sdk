
export interface ExUnits {
  exUnitsMem: number
  exUnitsSteps: number
}

export interface AlonzoGenesis {
  adaPerUTxOWord: number
  executionPrices: {
    prMem: number
    prSteps: number
  }
  maxTxExUnits: ExUnits
  maxBlockExUnits: ExUnits
  maxValueSize: number
  collateralPercentage: number
  maxCollateralInputs: number
}
