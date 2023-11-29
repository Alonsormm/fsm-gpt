import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'dfa_tester_state.dart';

class DFATesterCubit extends Cubit<DFATesterState> {
  DFATesterCubit()
      : super(const DFATesterSettingUp(evaluateDelay: 1, input: ""));

  void setEvaluateDelay(double evaluateDelay) {
    switch (state.runtimeType) {
      case DFATesterFinished:
      case DFATesterSettingUp:
        resetAfterFinished();
        emit((state as DFATesterSettingUp)
            .copyWith(evaluateDelay: evaluateDelay));
        break;
      case DFATesterEvaluating:
        final evaluatingState = state as DFATesterEvaluating;
        evaluatingState.timer.cancel();
        emit(evaluatingState.copyWith(
          evaluateDelay: evaluateDelay,
          timer: Timer.periodic(
            Duration(milliseconds: evaluateDelay * 1000 ~/ 1),
            (_) => evaluatingState.onTimerTick(),
          ),
        ));
        break;
    }
  }

  void setInput(String input) {
    switch (state.runtimeType) {
      case DFATesterSettingUp:
        emit((state as DFATesterSettingUp).copyWith(input: input));
        break;
      case DFATesterEvaluating:
        break;
      case DFATesterFinished:
        break;
    }
  }

  void startEvaluation(
      {required VoidCallback onTimerTick, required int initialState}) {
    switch (state.runtimeType) {
      case DFATesterFinished:
      case DFATesterSettingUp:
        resetAfterFinished();
        final settingUpState = state as DFATesterSettingUp;
        emit(DFATesterEvaluating(
          evaluateDelay: settingUpState.evaluateDelay,
          input: settingUpState.input,
          currentState: initialState,
          currentInputIndex: 0,
          timer: Timer.periodic(
            Duration(milliseconds: settingUpState.evaluateDelay * 1000 ~/ 1),
            (_) => onTimerTick(),
          ),
          onTimerTick: onTimerTick,
        ));
        break;
      case DFATesterEvaluating:
        break;
    }
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
      case DFATesterFinished:
        break;
    }
  }

  void resumeEvaluation() {
    switch (state.runtimeType) {
      case DFATesterSettingUp:
        break;
      case DFATesterEvaluating:
        final evaluatingState = state as DFATesterEvaluating;
        evaluatingState.timer.cancel();
        emit(evaluatingState.copyWith(
          timer: Timer.periodic(
            Duration(milliseconds: evaluatingState.evaluateDelay * 1000 ~/ 1),
            (_) => evaluatingState.onTimerTick(),
          ),
        ));
        break;
      case DFATesterFinished:
        break;
    }
  }

  void stopEvaluation(bool isAccepted) {
    switch (state.runtimeType) {
      case DFATesterSettingUp:
        break;
      case DFATesterEvaluating:
        final evaluatingState = state as DFATesterEvaluating;
        evaluatingState.timer.cancel();
        emit(DFATesterFinished(
          input: evaluatingState.input,
          currentState: evaluatingState.currentState,
          isAccepted: isAccepted,
          evaluateDelay: evaluatingState.evaluateDelay,
        ));
        break;
      case DFATesterFinished:
        break;
    }
  }

  void resetAfterFinished() {
    switch (state.runtimeType) {
      case DFATesterSettingUp:
        break;
      case DFATesterEvaluating:
        break;
      case DFATesterFinished:
        final finishedState = state as DFATesterFinished;
        emit(DFATesterSettingUp(
          evaluateDelay: finishedState.evaluateDelay,
          input: finishedState.input,
        ));
        break;
    }
  }

  void updateEvaluation({
    required int currentState,
    required int currentInputIndex,
  }) {
    switch (state.runtimeType) {
      case DFATesterSettingUp:
        break;
      case DFATesterEvaluating:
        final evaluatingState = state as DFATesterEvaluating;
        evaluatingState.timer.cancel();
        emit(evaluatingState.copyWith(
          currentState: currentState,
          currentInputIndex: currentInputIndex,
          timer: Timer.periodic(
            Duration(milliseconds: evaluatingState.evaluateDelay * 1000 ~/ 1),
            (_) => evaluatingState.onTimerTick(),
          ),
        ));
        break;
      case DFATesterFinished:
        break;
    }
  }
}
