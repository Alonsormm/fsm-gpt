part of 'automatico_flow_cubit.dart';

abstract class AutomaticoFlowState extends Equatable {
  const AutomaticoFlowState();

  @override
  List<Object?> get props => [];
}

class AutomaticoFlowStateSelectingType extends AutomaticoFlowState {
  const AutomaticoFlowStateSelectingType() : super();
}

class AutomaticoFlowInteracting extends AutomaticoFlowState {
  final FSMType type;
  final String? description;
  final bool isLoading;

  const AutomaticoFlowInteracting({
    required this.type,
    this.description,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [type, description, isLoading];

  AutomaticoFlowInteracting copyWith({
    String? description,
    bool? isLoading,
  }) {
    return AutomaticoFlowInteracting(
      type: type,
      description: description ?? this.description,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AutomaticoGenerated extends AutomaticoFlowState {
  final String description;
  final String raw;
  final FSMType type;

  final DFA? dfa;
  final NFA? nfa;
  final PushdownAutomaton? pda;
  final TuringMachine? turingMachine;

  const AutomaticoGenerated({
    required this.description,
    required this.type,
    required this.raw,
    this.dfa,
    this.nfa,
    this.pda,
    this.turingMachine,
  });

  @override
  List<Object?> get props =>
      [description, type, raw, dfa, nfa, pda, turingMachine];
}
