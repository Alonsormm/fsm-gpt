part of 'turing_machine_tester_cubit.dart';

abstract class TuringMachineTesterState extends Equatable {
  final String input;
  final double timerDuration;

  const TuringMachineTesterState(
      {required this.input, required this.timerDuration});

  @override
  List<Object?> get props => [input, timerDuration];
}

class TuringMachineTesterSettingUp extends TuringMachineTesterState {
  const TuringMachineTesterSettingUp({
    super.timerDuration = 2.0,
    required super.input,
  });
}

class TuringMachineTesterEvaluating extends TuringMachineTesterState {
  final TuringState currentState;
  final List<String> tape;
  final int headPosition;
  final Timer timer;
  final bool isAccepted;
  final bool isFinished;

  const TuringMachineTesterEvaluating({
    required this.currentState,
    required this.tape,
    required this.headPosition,
    required this.timer,
    this.isAccepted = false,
    this.isFinished = false,
    required super.input,
    super.timerDuration = 2.0,
  });

  @override
  List<Object?> get props => [
        input,
        currentState,
        tape,
        headPosition,
        timer,
        isAccepted,
        isFinished,
      ];

  TuringMachineTesterEvaluating copyWith({
    TuringState? currentState,
    List<String>? tape,
    int? headPosition,
    Timer? timer,
    bool? isAccepted,
    bool? isFinished,
  }) {
    return TuringMachineTesterEvaluating(
      input: input,
      currentState: currentState ?? this.currentState,
      tape: tape ?? this.tape,
      headPosition: headPosition ?? this.headPosition,
      timer: timer ?? this.timer,
      isAccepted: isAccepted ?? this.isAccepted,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class TuringMachineTesterError extends TuringMachineTesterState {
  final String errorMessage;

  const TuringMachineTesterError({
    required this.errorMessage,
    required super.input,
    super.timerDuration = 2.0,
  });

  @override
  List<Object?> get props => [input, errorMessage];
}
