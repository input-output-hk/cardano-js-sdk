import * as t from 'io-ts'

const transactionInputPointer = t.type({
  index: t.number,
  id: t.string
})

const transactionInputAddressing = t.type({
  account: t.number,
  change: t.number,
  index: t.number
})

export const TransactionInputCodec = t.intersection([
  t.interface({
    pointer: transactionInputPointer,
    value: t.string
  }),
  t.partial({ addressing: transactionInputAddressing })
])

export type TransactionInput = t.TypeOf<typeof TransactionInputCodec>
