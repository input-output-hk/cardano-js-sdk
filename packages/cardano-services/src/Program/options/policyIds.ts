import { Cardano, NotImplementedError } from '@cardano-sdk/core';
import { Command, Option } from 'commander';
import { readFile } from 'fs/promises';

const handlePolicyIdsParser = (policyIds: string) => policyIds.split(',').map(Cardano.PolicyId);

export enum HandlePolicyIdsOptionDescriptions {
  HandlePolicyIds = 'Handle policy Ids',
  HandlePolicyIdsFile = 'Handle policy Ids file'
}

export interface HandlePolicyIdsProgramOptions {
  handlePolicyIds: Cardano.PolicyId[];
  handlePolicyIdsFile?: string;
}

export const handlePolicyIdsFromFile = async (args: HandlePolicyIdsProgramOptions) => {
  const { handlePolicyIdsFile } = args;

  if (!handlePolicyIdsFile) return;

  args.handlePolicyIds = handlePolicyIdsParser(
    (await readFile(handlePolicyIdsFile, { encoding: 'utf8' })).replace(/\s/g, '')
  );
};

export const withHandlePolicyIdsOptions = (command: Command, maxPolicyIdsSupported?: number) =>
  command
    .addOption(
      new Option('--handle-policy-ids <handlePolicyIds>', HandlePolicyIdsOptionDescriptions.HandlePolicyIds)
        .env('HANDLE_POLICY_IDS')
        .argParser((policyIds: string) => {
          const policyIdsArray = handlePolicyIdsParser(policyIds);

          if (maxPolicyIdsSupported && policyIdsArray.length > maxPolicyIdsSupported) {
            throw new NotImplementedError(`${policyIdsArray.length} policyIds are not supported`);
          }

          return policyIdsArray;
        })
    )
    .addOption(
      new Option(
        '--handle-policy-ids-file <handlePolicyIdsFile>',
        HandlePolicyIdsOptionDescriptions.HandlePolicyIdsFile
      )
        .env('HANDLE_POLICY_IDS_FILE')
        .conflicts('handlePolicyIds')
    );
