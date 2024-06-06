import { Option } from 'commander';
import type { Command } from 'commander';

export const addOptions = (command: Command, options: Option[]) => {
  for (const option of options) command.addOption(option);

  return command;
};

export const newOption = <T>(
  flags: string,
  description: string,
  envName: string,
  argParser?: (value: string, previous: T) => T,
  defaultValue?: unknown
) => {
  const option = new Option(flags, description).env(envName);

  if (argParser !== undefined) option.argParser(argParser);
  if (defaultValue !== undefined) option.default(defaultValue);

  return option;
};
