import { Cardano } from '@cardano-sdk/core';
import { from } from 'rxjs';
import { unifiedProjectorOperator } from '@cardano-sdk/projection';
import type { BootstrapExtraProps, ProjectionEvent } from '@cardano-sdk/projection';
import type { WithTypeormContext } from './withTypeormTransaction.js';

// With 2023-03 mainnet protocol parameters this is good for:
// - >300 years
// - up to 100000 transactions per block
// - 10000 certificates per transaction
export const certificatePointerToId = ({ slot, certIndex, txIndex }: Cardano.Pointer) =>
  BigInt(slot) * 10_000_000_000n + BigInt(txIndex) * 10_000n + BigInt(certIndex);

export const MaxCertificatePointerIdTxIndex = Cardano.TxIndex(99_999);
export const MaxCertificatePointerIdCertificateIndex = Cardano.CertIndex(9999);

export const typeormOperator = <PropsIn = {}, PropsOut extends {} = {}>(
  op: (evt: ProjectionEvent<WithTypeormContext & PropsIn>) => Promise<{} extends PropsOut ? void : PropsOut>
) =>
  unifiedProjectorOperator<BootstrapExtraProps & WithTypeormContext & PropsIn, PropsOut>((evt) =>
    from(op(evt).then((result) => (typeof result === 'object' ? { ...evt, ...result } : evt)))
  );
