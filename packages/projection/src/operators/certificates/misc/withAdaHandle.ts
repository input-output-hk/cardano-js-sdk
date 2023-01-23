import { unifiedProjectorOperator } from '../../utils';

export interface AddressAlias {
  address: string;
  alias: string;
  protocol: string;
}

export interface WithAddressAliases {
  addressAliases: AddressAlias[];
}

export const withAdaHandle = unifiedProjectorOperator<{}, WithAddressAliases>((evt) => {
  // console.log('evt', evt);
  return [{ ...evt, addressAliases: { address: '', alias: '', protocol: '' } }];
});
