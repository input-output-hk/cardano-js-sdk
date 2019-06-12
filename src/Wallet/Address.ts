export interface Address {
  address: string
  index: number
  type: AddressType
  accountIndex: number
}

/** internal = change address & external = receipt address */
export enum AddressType {
  internal = 'Internal',
  external = 'External'
}
