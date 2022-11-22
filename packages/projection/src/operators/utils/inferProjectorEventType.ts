import { ProjectorOperator } from '../../types';

/**
 * Wrap an operator to easily infer extra props of source observable
 */
export const inferProjectorEventType =
  <
    OperatorExtraRollForwardPropsIn,
    OperatorExtraRollBackwardPropsIn,
    ExtraRollForwardPropsOut,
    ExtraRollBackwardPropsOut
  >(
    operator: ProjectorOperator<
      OperatorExtraRollForwardPropsIn,
      OperatorExtraRollBackwardPropsIn,
      ExtraRollForwardPropsOut,
      ExtraRollBackwardPropsOut
    >
  ) =>
  <
    SourceExtraRollForwardPropsIn extends OperatorExtraRollForwardPropsIn,
    SourceExtraRollBackwardPropsIn extends OperatorExtraRollBackwardPropsIn
  >(): ProjectorOperator<
    SourceExtraRollForwardPropsIn,
    SourceExtraRollBackwardPropsIn,
    ExtraRollForwardPropsOut,
    ExtraRollBackwardPropsOut
  > =>
    operator;
