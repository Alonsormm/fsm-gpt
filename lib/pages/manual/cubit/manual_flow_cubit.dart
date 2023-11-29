import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fsm_gpt/enums/fsm_type.dart';

part './manual_flow_state.dart';

class ManualFlowCubit extends Cubit<ManualFlowState> {
  ManualFlowCubit() : super(const ManualFlowStateSelectingType());

  void startInteracting(FSMType type) {
    if (state is! ManualFlowStateSelectingType) {
      throw Exception("Can't start interacting without selecting type");
    }
    emit(ManualFlowStateInteracting(type: type));
  }
}
