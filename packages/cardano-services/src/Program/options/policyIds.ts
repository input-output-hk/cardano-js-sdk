import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import { Command, Option } from 'commander';

const handlePolicyIdsParser = (policyIds: string) => policyIds.split(',').map(Cardano.PolicyId);

export enum HandlePolicyIdsOptionDescriptions {
  HandlePolicyIds = 'Handle policy Ids'
}

export interface HandlePolicyIdsProgramOptions {
  handlePolicyIds: Cardano.PolicyId[];
}

export const withHandlePolicyIdsOptions = (command: Command, maxPolicyIdsSupported?: number) =>
  command.addOption(
    new Option('--handle-policy-ids <handlePolicyIds>', HandlePolicyIdsOptionDescriptions.HandlePolicyIds)
      .env('HANDLE_POLICY_IDS')
      .argParser((policyIds: string) => {
        const policyIdsArray = handlePolicyIdsParser(policyIds);

        if (maxPolicyIdsSupported && policyIdsArray.length > maxPolicyIdsSupported) {
          throw new NotImplementedError(`${policyIdsArray.length} policyIds are not supported`);
        }

        return policyIdsArray;
      })
  );
