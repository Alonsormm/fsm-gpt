import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fsm_gpt/models/pda.dart';
part 'pda_tester_state.dart';

class PDATesterCubit extends Cubit<PDATesterState> {
  final PDA pda;

  PDATesterCubit({required this.pda})
      : super(const PDATesterSettingUp(
            evaluateDelay: 2, input: "", stack: ["Z0"]));

  void setEvaluateDelay(double evaluateDelay) {
    if (state is PDATesterSettingUp) {
      emit((state as PDATesterSettingUp).copyWith(
        evaluateDelay: evaluateDelay,
      ));
    }
  }

  void setInput(String input) {
    reset();
    emit((state as PDATesterSettingUp).copyWith(input: input));
  }

  void startEvaluation() {
    reset();
    final settingUpState = state as PDATesterSettingUp;
    _createEvaluatingState(settingUpState);
  }

  void calculateNextStep() {
    final evaluatingState = state as PDATesterEvaluating;
    if (evaluatingState.isFinished) {
      return;
    }

    final currentIndex = evaluatingState.currentInputIndex;
    final currentStack = evaluatingState.stack;
    final inputIsFinished = currentIndex >= evaluatingState.input.length;

    final (nextStates, nextStackSymbols) = pda.nextStates(
      evaluatingState.currentStates,
      inputIsFinished ? 'ε' : evaluatingState.input[currentIndex],
      currentStack,
    );

    if (nextStates.isEmpty) {
      _stopEvaluatingState(evaluatingState.isAccepted);
      return;
    }

    final isAccepted = nextStates.any((state) => pda.isFinalState(state));

    emit(
      evaluatingState.copyWith(
        currentStates: nextStates,
        stack: nextStackSymbols,
        currentInputIndex: currentIndex + (inputIsFinished ? 0 : 1),
        isAccepted: isAccepted,
        isFinished: inputIsFinished && nextStates.isEmpty,
      ),
    );
  }

  void _createEvaluatingState(PDATesterSettingUp settingUpState) {
    var initialState = {pda.initialState};
    var initialStack = List<String>.from(settingUpState.stack);

    emit(PDATesterEvaluating(
      evaluateDelay: settingUpState.evaluateDelay,
      input: settingUpState.input,
      currentStates: initialState,
      stack: initialStack,
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
      PDATesterSettingUp(
        evaluateDelay: state.evaluateDelay,
        input: state.input,
        stack: const ["Z0"],
      ),
    );
  }

  void _stopEvaluatingState(bool isAccepted) {
    final evaluatingState = state as PDATesterEvaluating;
    evaluatingState.timer.cancel();
    emit(
      evaluatingState.copyWith(
        isAccepted: isAccepted,
        isFinished: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    if (state is PDATesterEvaluating) {
      (state as PDATesterEvaluating).timer.cancel();
    }
    super.close();
  }
}
