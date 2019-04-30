import * as t from 'io-ts'

const transactionOutputRequiredFields = t.type({
  address: t.string,
  value: t.string
})

const transactionOutputFullAddress = t.type({
  cadAmount: t.interface({
    getCCoin: t.number
  }),
  cadId: t.string,
  cadIsUsed: t.boolean,
  account: t.number,
  change: t.number,
  index: t.number
})

const transactionOutputOptionalFields = t.partial({
  isChange: t.boolean,
  fullAddress: transactionOutputFullAddress
})

export const TransactionOutputCodec = t.intersection([
  transactionOutputRequiredFields,
  transactionOutputOptionalFields
])

export type TransactionOutput = t.TypeOf<typeof TransactionOutputCodec>
