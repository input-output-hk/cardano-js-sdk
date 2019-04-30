import * as t from 'io-ts'

const pointer = t.type({
  index: t.number,
  id: t.string
})

const addressing = t.type({
  account: t.number,
  change: t.number,
  index: t.number
})

export const TransactionInputCodec = t.intersection([
  t.interface({
    pointer,
    value: t.string
  }),
  t.partial({ addressing })
])

export type TransactionInput = t.TypeOf<typeof TransactionInputCodec>
