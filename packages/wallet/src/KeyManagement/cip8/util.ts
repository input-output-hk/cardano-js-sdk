import { Int, Label } from '@emurgo/cardano-message-signing-nodejs';

export const CoseLabel = {
  address: Label.new_text('address'),
  crv: Label.new_int(Int.new_i32(-1)),
  x: Label.new_int(Int.new_i32(-2))
};
