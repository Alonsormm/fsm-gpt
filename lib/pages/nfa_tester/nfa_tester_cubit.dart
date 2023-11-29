import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fsm_gpt/models/nfa.dart';
part 'nfa_tester_state.dart'; // Part file for NFA states

class NFATesterCubit extends Cubit<NFATesterState> {
  final NFA nfa;

  NFATesterCubit({required this.nfa})
      : super(const NFATesterSettingUp(evaluateDelay: 2, input: ""));

  void setEvaluateDelay(double evaluateDelay) {
    if (state is NFATesterSettingUp) {
      emit((state as NFATesterSettingUp).copyWith(
        evaluateDelay: evaluateDelay,
      ));
    }
  }

  void setInput(String input) {
    reset();
    emit((state as NFATesterSettingUp).copyWith(input: input));
  }

  void startEvaluation() {
    reset();
    final settingUpState = state as NFATesterSettingUp;
    _createEvaluatingState(settingUpState);
  }

  void calculateNextStep() {
    final evaluatingState = state as NFATesterEvaluating;
    if (evaluatingState.isFinished) {
      return;
    }

    final currentIndex = evaluatingState.currentInputIndex;

    final nextStates = nfa.nextStates(
      evaluatingState.currentStates,
      evaluatingState.input[evaluatingState.currentInputIndex],
    );

    evaluatingState.timer.cancel();
    if (nextStates.isEmpty) {
      stopEvaluation(false);
      return;
    }

    final timer = Timer.periodic(
      Duration(milliseconds: evaluatingState.evaluateDelay * 1000 ~/ 1),
      (_) => calculateNextStep(),
    );

    emit(evaluatingState.copyWith(
      evaluateDelay: evaluatingState.evaluateDelay,
      currentStates: nextStates,
      currentInputIndex: currentIndex + 1,
      isAccepted: nextStates.any((state) => nfa.finalStates.contains(state)),
      timer: timer,
    ));
  }

  void _createEvaluatingState(NFATesterSettingUp settingUpState) {
    emit(NFATesterEvaluating(
      evaluateDelay: settingUpState.evaluateDelay,
      input: settingUpState.input,
      currentStates: {nfa.initialState},
      currentInputIndex: 0,
      timer: Timer.periodic(
        Duration(milliseconds: settingUpState.evaluateDelay * 1000 ~/ 1),
        (_) => calculateNextStep(),
      ),
    ));
  }

  void stopEvaluation(bool isAccepted) {
    _stopEvaluatingState(isAccepted);
  }

  void reset() {
    emit(
      NFATesterSettingUp(
        evaluateDelay: state.evaluateDelay,
        input: state.input,
      ),
    );
  }

  void _stopEvaluatingState(bool isAccepted) {
    final evaluatingState = state as NFATesterEvaluating;
    evaluatingState.timer.cancel();
    emit(
      evaluatingState.copyWith(
        timer: Timer(const Duration(days: 1), () {}),
        isAccepted: isAccepted,
      ),
    );
  }

  @override
  Future<void> close() async {
    if (state is NFATesterEvaluating) {
      (state as NFATesterEvaluating).timer.cancel();
    }
    super.close();
  }
}
