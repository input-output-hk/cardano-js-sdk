import type { ExtChainSyncOperator } from '../../types.js';

/** Wrap an operator to easily infer extra props of source observable */
export const inferProjectorEventType =
  <
    OperatorExtraRollForwardPropsIn,
    OperatorExtraRollBackwardPropsIn,
    ExtraRollForwardPropsOut,
    ExtraRollBackwardPropsOut
  >(
    operator: ExtChainSyncOperator<
      OperatorExtraRollForwardPropsIn,
      OperatorExtraRollBackwardPropsIn,
      ExtraRollForwardPropsOut,
      ExtraRollBackwardPropsOut
    >
  ) =>
  <
    SourceExtraRollForwardPropsIn extends OperatorExtraRollForwardPropsIn,
    SourceExtraRollBackwardPropsIn extends OperatorExtraRollBackwardPropsIn
  >(): ExtChainSyncOperator<
    SourceExtraRollForwardPropsIn,
    SourceExtraRollBackwardPropsIn,
    ExtraRollForwardPropsOut,
    ExtraRollBackwardPropsOut
  > =>
    operator;
