import * as t from 'io-ts'

const requiredFields = t.type({
  address: t.string,
  value: t.string
})

const fullAddress = t.type({
  cadAmount: t.interface({
    getCCoin: t.number
  }),
  cadId: t.string,
  cadIsUsed: t.boolean,
  change: t.number,
  index: t.number
})

const optionalFields = t.partial({
  isChange: t.boolean,
  fullAddress
})

export const TransactionOutputCodec = t.intersection([
  requiredFields,
  optionalFields
])

export type TransactionOutput = t.TypeOf<typeof TransactionOutputCodec>
