part of './manual_flow_cubit.dart';

abstract class ManualFlowState extends Equatable {
  const ManualFlowState();

  @override
  List<Object?> get props => [];
}

class ManualFlowStateSelectingType extends ManualFlowState {
  const ManualFlowStateSelectingType() : super();
}

class ManualFlowStateInteracting extends ManualFlowState {
  final FSMType type;

  const ManualFlowStateInteracting({
    required this.type,
  });

  @override
  List<Object?> get props => [type];
}
