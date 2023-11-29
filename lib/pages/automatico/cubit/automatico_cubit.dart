import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/services/fsm_from_text_service.dart';

part 'automatico_state.dart';

class AutomaticoCubit extends Cubit<AutomaticoCubitState> {
  AutomaticoCubit() : super(const AutomaticoSettingUp());

  void setDescription(String description) {
    if (state is! AutomaticoSettingUp) {
      return;
    }
    emit(AutomaticoSettingUp(description: description));
  }

  Future<void> loadDFA() async {
    if (state is! AutomaticoSettingUp) {
      return;
    }
    emit(AutomaticoLoading(description: state.description!));
    final dfa =
        await FSMFromTextService.generateDFAFromText(state.description!);
    emit(
      AutomaticoLoaded(description: 'DFA loaded', dfa: dfa),
    );
  }
}
