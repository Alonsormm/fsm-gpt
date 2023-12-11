import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fsm_gpt/models/dfa.dart';

part 'dfa_tester_state.dart';

class DFATesterCubit extends Cubit<DFATesterState> {
  final DFA dfa;

  DFATesterCubit({required this.dfa})
      : super(const DFATesterSettingUp(evaluateDelay: 1, input: ""));

  void setEvaluateDelay(double evaluateDelay) {
    if (state is DFATesterSettingUp) {
      emit((state as DFATesterSettingUp).copyWith(
        evaluateDelay: evaluateDelay,
      ));
    }
  }

  void setInput(String input) {
    reset();
    emit((state as DFATesterSettingUp).copyWith(input: input));
  }

  void startEvaluation() {
    reset();
    final settingUpState = state as DFATesterSettingUp;
    _createEvaluatingState(settingUpState);
  }

  void pauseEvaluation() {
    switch (state.runtimeType) {
      case DFATesterSettingUp:
        break;
      case DFATesterEvaluating:
        final evaluatingState = state as DFATesterEvaluating;
        evaluatingState.timer.cancel();
        emit(evaluatingState.copyWith(timer: Timer(Duration.zero, () {})));
        break;
    }
  }

  void stopEvaluation(bool isAccepted) {
    if (state is DFATesterSettingUp) {
      return;
    }
    final evaluatingState = state as DFATesterEvaluating;

    emit(
      evaluatingState.copyWith(
        timer: Timer(const Duration(days: 1), () {}),
        isAccepted: isAccepted,
      ),
    );
  }

  void reset() {
    if (state is DFATesterEvaluating) {
      (state as DFATesterEvaluating).timer.cancel();
    }
    emit(DFATesterSettingUp(
      evaluateDelay: state.evaluateDelay,
      input: state.input,
    ));
  }

  void calculateNextStep() {
    final evaluatingState = state as DFATesterEvaluating;
    if (evaluatingState.isFinished) {
      return;
    }

    final currentIndex = evaluatingState.currentInputIndex;

    final nextState = dfa.nextState(
      evaluatingState.currentState,
      evaluatingState.input[evaluatingState.currentInputIndex],
    );

    evaluatingState.timer.cancel();
    if (nextState == null) {
      stopEvaluation(false);
      return;
    }

    final timer = Timer.periodic(
      Duration(milliseconds: evaluatingState.evaluateDelay * 1000 ~/ 1),
      (_) => calculateNextStep(),
    );

    emit(evaluatingState.copyWith(
      evaluateDelay: evaluatingState.evaluateDelay,
      currentState: nextState,
      currentInputIndex: currentIndex + 1,
      isAccepted: dfa.finalStates.contains(nextState),
      timer: timer,
    ));
  }

  void _createEvaluatingState(DFATesterSettingUp settingUpState) {
    emit(DFATesterEvaluating(
      evaluateDelay: settingUpState.evaluateDelay,
      input: settingUpState.input,
      currentState: dfa.initialState,
      currentInputIndex: 0,
      timer: Timer.periodic(
        Duration(milliseconds: settingUpState.evaluateDelay * 1000 ~/ 1),
        (_) => calculateNextStep(),
      ),
    ));
  }
}
