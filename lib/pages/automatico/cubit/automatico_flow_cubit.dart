import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fsm_gpt/enums/fsm_type.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/models/nfa.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
import 'package:fsm_gpt/services/fsm_from_text_service.dart';

part 'automatico_flow_state.dart';

class AutomaticoFlowCubit extends Cubit<AutomaticoFlowState> {
  AutomaticoFlowCubit() : super(const AutomaticoFlowStateSelectingType());

  void startInteracting(FSMType type) {
    if (state is! AutomaticoFlowStateSelectingType) {
      throw Exception("Can't start interacting without selecting type");
    }
    emit(AutomaticoFlowInteracting(type: type));
  }

  void updateDescription(String description) {
    if (state is! AutomaticoFlowInteracting) {
      throw Exception("Can't update description without interacting");
    }
    emit((state as AutomaticoFlowInteracting)
        .copyWith(description: description));
  }

  Future<void> generate() async {
    if (state is! AutomaticoFlowInteracting) {
      throw Exception("Can't generate without interacting");
    }
    emit((state as AutomaticoFlowInteracting).copyWith(isLoading: true));
    final description = (state as AutomaticoFlowInteracting).description;
    final type = (state as AutomaticoFlowInteracting).type;
    switch (type) {
      case FSMType.dfa:
        final (dfa, raw) =
            await FSMFromTextService.generateDFAFromText(description!);
        emit(AutomaticoGenerated(
          description: description,
          type: type,
          raw: raw,
          dfa: dfa,
        ));
        break;
      case FSMType.nfa:
        final (nfa, raw) =
            await FSMFromTextService.generateNFAFromText(description!);
        emit(AutomaticoGenerated(
          description: description,
          type: type,
          raw: raw,
          nfa: nfa,
        ));
        break;
      case FSMType.pda:
        final (pda, raw) =
            await FSMFromTextService.generatePDAFromText(description!);
        emit(AutomaticoGenerated(
          description: description,
          type: type,
          raw: raw,
          pda: pda,
        ));
        break;
      case FSMType.turing:
        final (turingMachine, raw) =
            await FSMFromTextService.generateTuringMachineFromText(
                description!);
        emit(AutomaticoGenerated(
          description: description,
          type: type,
          raw: raw,
          turingMachine: turingMachine,
        ));
        break;
      default:
        throw Exception("Not supported yet");
    }
  }
}
