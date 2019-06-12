import * as t from 'io-ts'

const pointer = t.type({
  index: t.number,
  id: t.string
})

const addressing = t.type({
  change: t.number,
  index: t.number,
  accountIndex: t.number
})

const value = t.type({
  address: t.string,
  value: t.string
})

export const TransactionInputCodec = t.intersection([
  t.interface({
    pointer,
    value
  }),
  t.partial({ addressing })
])

export type TransactionInput = t.TypeOf<typeof TransactionInputCodec>
