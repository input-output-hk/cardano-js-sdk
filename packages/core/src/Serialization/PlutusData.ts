import * as Cardano from '../Cardano';
import { CML, cmlToCore, coreToCml } from '../CML';
import { HexBlob, usingAutoFree } from '@cardano-sdk/util';
import { isAnyPlutusDataCollection } from '../Cardano/util';

export class PlutusData {
  #corePlutusData: Cardano.PlutusData;

  constructor(corePlutusData: Cardano.PlutusData) {
    this.#corePlutusData = corePlutusData;
  }

  static fromCbor(cbor: HexBlob): PlutusData {
    return new PlutusData(
      usingAutoFree((scope) => cmlToCore.plutusData(scope.manage(CML.PlutusData.from_bytes(Buffer.from(cbor, 'hex')))))
    );
  }

  static fromCore(plutusData: Cardano.PlutusData) {
    return new PlutusData(plutusData);
  }

  toCbor(): HexBlob {
    if (isAnyPlutusDataCollection(this.#corePlutusData) && this.#corePlutusData.cbor) {
      return this.#corePlutusData.cbor;
    }

    return HexBlob(
      Buffer.from(usingAutoFree((scope) => coreToCml.plutusData(scope, this.#corePlutusData).to_bytes())).toString(
        'hex'
      )
    );
  }

  toCore(): Cardano.PlutusData {
    return this.#corePlutusData;
  }
}
