import convict from 'convict';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(__dirname, '../../../../.env') });

convict.addFormat({
  coerce: (val) => Number.parseInt(val, 10),
  name: 'number',
  validate(val) {
    if (Number.isNaN(Number.parseInt(val)) || !Number.isInteger(val) || val < 0) {
      throw new TypeError('Must be a positive integer value');
    }
  }
});

convict.addFormat({
  name: 'weights',
  validate(values) {
    for (const val of values) {
      if (Number.isNaN(Number.parseFloat(val)) || val < 0) throw new TypeError('Weights must be positive numbers');
    }
  }
});

export type ValueTransferConfig = {
  amount: { max: number; min: number };
  count: { max: number; min: number };
  period: number;
};

export const configLoader = convict({
  iterations: {
    default: 10,
    doc: 'How many iterations will be executed before stopping the test.',
    format: 'number'
  },
  stakeDistribution: {
    default: [1], // 100 % to the first stake index.
    doc: 'The distribution of stake between stake indices. This distribution is expressed in weights',
    format: 'weights',
    nullable: false
  },
  startingFunds: {
    default: 1_000_000_000, // 1000 ADA
    doc: 'Starting funds of the newly created wallet.',
    format: 'number',
    nullable: false
  },
  utxoIn: {
    amount: {
      max: {
        default: 1_000_000, // 1 ADA
        doc: 'The maximum amount of the input (inclusive)',
        format: 'number'
      },
      min: {
        default: 1_000_000, // 1 ADA
        doc: 'The minimum amount of the input (inclusive)',
        format: 'number'
      }
    },
    count: {
      max: {
        default: 1,
        doc: 'The maximum number of inputs to be generated at each transaction',
        format: 'number'
      },
      min: {
        default: 1,
        doc: 'The minimum number of inputs to be generated at each transaction',
        format: 'number'
      }
    },
    period: {
      default: 0,
      doc: 'How frequently the wallet will receive inputs.',
      format: 'number'
    }
  },
  utxoOut: {
    amount: {
      max: {
        default: 1_000_000, // 1 ADA
        doc: 'The maximum amount of the output (inclusive)',
        format: 'number'
      },
      min: {
        default: 1_000_000, // 1 ADA
        doc: 'The minimum amount of the output (inclusive)',
        format: 'number'
      }
    },
    count: {
      max: {
        default: 1,
        doc: 'The maximum number of outputs to be generated at each transaction',
        format: 'number'
      },
      min: {
        default: 1,
        doc: 'The minimum number of outputs to be generated at each transaction',
        format: 'number'
      }
    },
    period: {
      default: 0,
      doc: 'How frequently the wallet will generate outputs.',
      format: 'number'
    }
  }
});
