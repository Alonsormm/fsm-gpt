part of 'dfa_tester_cubit.dart';

abstract class DFATesterState extends Equatable {
  final double evaluateDelay;
  final String input;

  const DFATesterState({
    required this.evaluateDelay,
    required this.input,
  });

  @override
  List<Object?> get props => [];
}

class DFATesterSettingUp extends DFATesterState {
  const DFATesterSettingUp({
    required super.evaluateDelay,
    required super.input,
  });

  @override
  List<Object?> get props => [evaluateDelay, input];

  DFATesterSettingUp copyWith({
    double? evaluateDelay,
    String? input,
  }) {
    return DFATesterSettingUp(
      evaluateDelay: evaluateDelay ?? super.evaluateDelay,
      input: input ?? super.input,
    );
  }
}

class DFATesterEvaluating extends DFATesterState {
  final int currentState;
  final int currentInputIndex;
  final Timer timer;
  final VoidCallback onTimerTick;

  const DFATesterEvaluating({
    required super.evaluateDelay,
    required super.input,
    required this.currentState,
    required this.timer,
    this.currentInputIndex = 0,
    required this.onTimerTick,
  });

  @override
  List<Object?> get props =>
      [evaluateDelay, input, currentState, timer, currentInputIndex];

  DFATesterEvaluating copyWith({
    double? evaluateDelay,
    String? input,
    int? currentState,
    Timer? timer,
    int? currentInputIndex,
    VoidCallback? onTimerTick,
  }) {
    return DFATesterEvaluating(
      evaluateDelay: evaluateDelay ?? super.evaluateDelay,
      input: input ?? super.input,
      currentState: currentState ?? this.currentState,
      timer: timer ?? this.timer,
      currentInputIndex: currentInputIndex ?? this.currentInputIndex,
      onTimerTick: onTimerTick ?? this.onTimerTick,
    );
  }
}

class DFATesterFinished extends DFATesterState {
  final int currentState;
  final bool isAccepted;

  const DFATesterFinished({
    required super.evaluateDelay,
    required super.input,
    required this.currentState,
    required this.isAccepted,
  });

  @override
  List<Object?> get props => [evaluateDelay, input, currentState, isAccepted];

  DFATesterFinished copyWith({
    double? evaluateDelay,
    String? input,
    int? currentState,
    bool? isAccepted,
  }) {
    return DFATesterFinished(
      evaluateDelay: evaluateDelay ?? super.evaluateDelay,
      input: input ?? super.input,
      currentState: currentState ?? this.currentState,
      isAccepted: isAccepted ?? this.isAccepted,
    );
  }
}

class DFATesterError extends DFATesterState {
  final String currentState;
  final String errorMessage;

  const DFATesterError({
    required super.evaluateDelay,
    required super.input,
    required this.currentState,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [evaluateDelay, input, currentState, errorMessage];

  DFATesterError copyWith({
    double? evaluateDelay,
    String? input,
    String? currentState,
    String? errorMessage,
  }) {
    return DFATesterError(
      evaluateDelay: evaluateDelay ?? super.evaluateDelay,
      input: input ?? super.input,
      currentState: currentState ?? this.currentState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
