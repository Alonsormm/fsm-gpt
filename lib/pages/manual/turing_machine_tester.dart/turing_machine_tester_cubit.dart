import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
part 'turing_machine_tester_state.dart';

class TuringMachineTesterCubit extends Cubit<TuringMachineTesterState> {
  final TuringMachine turingMachine;

  TuringMachineTesterCubit({required this.turingMachine})
      : super(const TuringMachineTesterSettingUp(input: ''));

  void setInput(String input) {
    emit(TuringMachineTesterSettingUp(input: input));
  }

  void setTimerDuration(double timerDuration) {
    final settingUpState = state as TuringMachineTesterSettingUp;
    emit(TuringMachineTesterSettingUp(
      input: settingUpState.input,
      timerDuration: timerDuration,
    ));
  }

  void startEvaluation() {
    final settingUpState = state as TuringMachineTesterSettingUp;
    _createEvaluatingState(settingUpState);
  }

  void step() {
    if (state is! TuringMachineTesterEvaluating) {
      return;
    }
    final evaluatingState = state as TuringMachineTesterEvaluating;
    if (evaluatingState.isFinished) {
      return;
    }

    final (nextState, nextTape, headPosition) = turingMachine.nextStep(
      evaluatingState.currentState,
      evaluatingState.tape,
      evaluatingState.headPosition,
    );

    if (nextState == null) {
      _stopEvaluatingState(evaluatingState.isAccepted);
      return;
    }

    final isAccepted = turingMachine.acceptanceStates.contains(nextState);

    emit(
      evaluatingState.copyWith(
        currentState: nextState,
        tape: nextTape,
        headPosition: headPosition,
        isAccepted: isAccepted,
        isFinished: isAccepted,
      ),
    );

    if (isAccepted) {
      _stopEvaluatingState(isAccepted);
    }
  }

  void _stopEvaluatingState(bool isAccepted) {
    final evaluatingState = state as TuringMachineTesterEvaluating;
    evaluatingState.timer.cancel();
    emit(evaluatingState.copyWith(isAccepted: isAccepted, isFinished: true));
  }

  void _createEvaluatingState(TuringMachineTesterSettingUp settingUpState) {
    var initialState = turingMachine.initialState;
    var initialTape = settingUpState.input.split('');
    // add _ at start of tape if needed
    if (initialTape.isEmpty || initialTape.first != '_') {
      initialTape.insert(0, '_');
    }
    // add _ at end of tape if needed
    if (initialTape.isEmpty || initialTape.last != '_') {
      initialTape.add('_');
    }
    var initialHeadPosition = 1;

    emit(TuringMachineTesterEvaluating(
      input: settingUpState.input,
      currentState: initialState,
      tape: initialTape,
      headPosition: initialHeadPosition,
      timer: Timer.periodic(
        Duration(seconds: settingUpState.timerDuration.toInt()),
        (_) => step(),
      ),
    ));
  }

  void reset() {
    if (state is TuringMachineTesterEvaluating) {
      (state as TuringMachineTesterEvaluating).timer.cancel();
    }
    emit(TuringMachineTesterSettingUp(input: state.input));
  }

  @override
  Future<void> close() async {
    if (state is TuringMachineTesterEvaluating) {
      (state as TuringMachineTesterEvaluating).timer.cancel();
    }
    super.close();
  }
}
