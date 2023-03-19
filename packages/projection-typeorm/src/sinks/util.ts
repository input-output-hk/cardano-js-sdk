// With 2023-03 mainnet protocol parameters this is good for:
// - >300 years
// - up to 100000 transactions per block

import { Operators } from '@cardano-sdk/projection';

// - 10000 certificates per transaction
export const certificatePointerToId = ({ slot, certIndex, txIndex }: Operators.CertificatePointer) =>
  BigInt(slot) * 10_000_000_000n + BigInt(txIndex) * 10_000n + BigInt(certIndex);

export const MaxCertificatePointerIdTxIndex = 99_999;
export const MaxCertificatePointerIdCertificateIndex = 9999;
