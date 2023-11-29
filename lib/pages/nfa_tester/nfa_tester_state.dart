part of 'nfa_tester_cubit.dart'; // Replace with the appropriate part directive

abstract class NFATesterState extends Equatable {
  final double evaluateDelay;
  final String input;

  const NFATesterState({
    required this.evaluateDelay,
    required this.input,
  });

  @override
  List<Object?> get props => [evaluateDelay, input];
}

class NFATesterSettingUp extends NFATesterState {
  const NFATesterSettingUp({
    required super.evaluateDelay,
    required super.input,
  });

  NFATesterSettingUp copyWith({
    double? evaluateDelay,
    String? input,
  }) {
    return NFATesterSettingUp(
      evaluateDelay: evaluateDelay ?? this.evaluateDelay,
      input: input ?? this.input,
    );
  }
}

class NFATesterEvaluating extends NFATesterState {
  final Set<int> currentStates; // NFA can have multiple current states
  final int currentInputIndex;
  final Timer timer;
  final bool isAccepted;

  const NFATesterEvaluating({
    required super.evaluateDelay,
    required super.input,
    required this.currentStates,
    required this.timer,
    this.currentInputIndex = 0,
    this.isAccepted = false,
  });

  @override
  List<Object?> get props => [
        evaluateDelay,
        input,
        currentStates,
        timer,
        currentInputIndex,
        isAccepted
      ];

  NFATesterEvaluating copyWith({
    double? evaluateDelay,
    String? input,
    Set<int>? currentStates,
    Timer? timer,
    int? currentInputIndex,
    VoidCallback? onTimerTick,
    bool? isAccepted,
  }) {
    return NFATesterEvaluating(
      evaluateDelay: evaluateDelay ?? this.evaluateDelay,
      input: input ?? this.input,
      currentStates: currentStates ?? this.currentStates,
      timer: timer ?? this.timer,
      currentInputIndex: currentInputIndex ?? this.currentInputIndex,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }

  bool get isFinished => currentInputIndex == input.length;

  bool get isFinishedAndAccepted => isFinished && isAccepted;
}

class NFATesterError extends NFATesterState {
  final String errorMessage;

  const NFATesterError({
    required super.evaluateDelay,
    required super.input,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [evaluateDelay, input, errorMessage];

  NFATesterError copyWith({
    double? evaluateDelay,
    String? input,
    String? errorMessage,
  }) {
    return NFATesterError(
      evaluateDelay: evaluateDelay ?? this.evaluateDelay,
      input: input ?? this.input,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
