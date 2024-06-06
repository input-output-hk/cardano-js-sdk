import { CustomError } from 'ts-custom-error';
import type { OgmiosOptionDescriptions } from '../options/index.js';

export class MissingCardanoNodeOption extends CustomError {
  public constructor(option: OgmiosOptionDescriptions | OgmiosOptionDescriptions[]) {
    super();
    this.message = `Cardano Node Ogmios requires the ${
      Array.isArray(option) ? option.join(' or ') : option
    } program option.`;
  }
}
