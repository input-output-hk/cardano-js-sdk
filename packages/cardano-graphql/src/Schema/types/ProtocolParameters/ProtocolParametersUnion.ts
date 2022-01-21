import { ProtocolParametersAlonzo } from './ProtocolParametersAlonzo';
import { ProtocolParametersShelley } from './ProtocolParametersShelley';
import { createUnionType } from 'type-graphql';

export const ProtocolParameters = createUnionType({
  name: 'ProtocolParameters',
  resolveType: (value) => {
    if ('minPoolCost' in value) return ProtocolParametersAlonzo;
    return ProtocolParametersShelley;
  },
  types: () => [ProtocolParametersAlonzo, ProtocolParametersShelley] as const
});
