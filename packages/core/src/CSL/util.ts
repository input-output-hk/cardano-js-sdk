import { CardanoSerializationLib } from './loadCardanoSerializationLib';

export const MAX_U64 = 18_446_744_073_709_551_615n;
export const maxBigNum = (csl: CardanoSerializationLib) => csl.BigNum.from_str(MAX_U64.toString());
