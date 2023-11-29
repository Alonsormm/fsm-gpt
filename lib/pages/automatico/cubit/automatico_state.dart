part of 'automatico_cubit.dart';

abstract class AutomaticoCubitState extends Equatable {
  final String? description;
  const AutomaticoCubitState({this.description});

  @override
  List<Object?> get props => [description];
}

class AutomaticoSettingUp extends AutomaticoCubitState {
  const AutomaticoSettingUp({super.description});

  @override
  List<Object> get props => [description ?? ''];
}

class AutomaticoLoading extends AutomaticoCubitState {
  const AutomaticoLoading({required super.description});
}

class AutomaticoLoaded extends AutomaticoCubitState {
  final DFA dfa;

  const AutomaticoLoaded({required super.description, required this.dfa});
}

class AutomaticoError extends AutomaticoCubitState {
  final String error;

  const AutomaticoError({required super.description, required this.error});

  @override
  List<Object> get props => [description ?? '', error];
}
