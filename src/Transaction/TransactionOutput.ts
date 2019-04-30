export interface TransactionOutput {
  address: string
  value: string
  isChange?: boolean
  fullAddress?: {
    cadAmount: {
      getCCoin: number
    }
    cadId: string
    cadIsUsed: boolean
    account: number
    change: number
    index: number
  }
}
