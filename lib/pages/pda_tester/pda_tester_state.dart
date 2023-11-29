part of 'pda_tester_cubit.dart';

abstract class PDATesterState extends Equatable {
  final double evaluateDelay;
  final String input;
  final List<String> stack;

  const PDATesterState({
    required this.evaluateDelay,
    required this.input,
    required this.stack,
  });

  @override
  List<Object?> get props => [evaluateDelay, input, stack];
}

class PDATesterSettingUp extends PDATesterState {
  const PDATesterSettingUp({
    required double evaluateDelay,
    required String input,
    required List<String> stack,
  }) : super(evaluateDelay: evaluateDelay, input: input, stack: stack);

  PDATesterSettingUp copyWith({
    double? evaluateDelay,
    String? input,
    List<String>? stack,
  }) {
    return PDATesterSettingUp(
      evaluateDelay: evaluateDelay ?? this.evaluateDelay,
      input: input ?? this.input,
      stack: stack ?? this.stack,
    );
  }
}

class PDATesterEvaluating extends PDATesterState {
  final Set<PdaState> currentStates;
  final int currentInputIndex;
  final Timer timer;
  final bool isAccepted;
  final bool isFinished;

  const PDATesterEvaluating({
    required double evaluateDelay,
    required String input,
    required List<String> stack,
    required this.currentStates,
    required this.currentInputIndex,
    required this.timer,
    this.isAccepted = false,
    this.isFinished = false,
  }) : super(evaluateDelay: evaluateDelay, input: input, stack: stack);

  @override
  List<Object?> get props => [
        evaluateDelay,
        input,
        stack,
        currentStates,
        currentInputIndex,
        timer,
        isAccepted,
        isFinished,
      ];

  PDATesterEvaluating copyWith({
    double? evaluateDelay,
    String? input,
    List<String>? stack,
    Set<PdaState>? currentStates,
    int? currentInputIndex,
    Timer? timer,
    bool? isAccepted,
    bool? isFinished,
  }) {
    return PDATesterEvaluating(
      evaluateDelay: evaluateDelay ?? this.evaluateDelay,
      input: input ?? this.input,
      stack: stack ?? this.stack,
      currentStates: currentStates ?? this.currentStates,
      currentInputIndex: currentInputIndex ?? this.currentInputIndex,
      timer: timer ?? this.timer,
      isAccepted: isAccepted ?? this.isAccepted,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class PDATesterError extends PDATesterState {
  final String errorMessage;

  const PDATesterError({
    required double evaluateDelay,
    required String input,
    required List<String> stack,
    required this.errorMessage,
  }) : super(evaluateDelay: evaluateDelay, input: input, stack: stack);

  @override
  List<Object?> get props => [evaluateDelay, input, stack, errorMessage];

  PDATesterError copyWith({
    double? evaluateDelay,
    String? input,
    List<String>? stack,
    String? errorMessage,
  }) {
    return PDATesterError(
      evaluateDelay: evaluateDelay ?? this.evaluateDelay,
      input: input ?? this.input,
      stack: stack ?? this.stack,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
