import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:kartal/kartal.dart';

class TuringState extends Equatable {
  final int name;

  const TuringState(this.name);

  @override
  String toString() => 'q$name';

  @override
  List<Object?> get props => [name];
}

class TuringTransition extends Equatable {
  final TuringState currentState;
  final String currentSymbol;
  final TuringState nextState;
  final String newSymbol;
  final String direction; // 'L' for left, 'R' for right

  const TuringTransition({
    required this.currentState,
    required this.currentSymbol,
    required this.nextState,
    required this.newSymbol,
    required this.direction,
  });

  @override
  String toString() {
    return '($currentState, $currentSymbol) -> ($nextState, $newSymbol, $direction)';
  }

  @override
  List<Object?> get props => [
        currentState,
        currentSymbol,
        nextState,
        newSymbol,
        direction,
      ];
}

class TuringMachine {
  final Set<TuringState> states;
  final Set<String> tapeAlphabet;
  final Set<String> inputAlphabet;
  final List<TuringTransition> transitions;
  final TuringState initialState;
  final Set<TuringState> acceptanceStates;

  TuringMachine({
    required this.states,
    required this.tapeAlphabet,
    required this.inputAlphabet,
    required this.transitions,
    required this.initialState,
    required this.acceptanceStates,
  });

  bool evaluateString(String input) {
    var currentState = initialState;
    var currentSymbolIndex = 0;
    var tape = input.split('');
    var currentSymbol = tape[currentSymbolIndex];
    TuringTransition? currentTransition = transitions.firstWhere(
      (transition) =>
          transition.currentState == currentState &&
          transition.currentSymbol == currentSymbol,
    );
    while (currentTransition != null) {
      tape[currentSymbolIndex] = currentTransition.newSymbol;
      if (currentTransition.direction == 'R') {
        currentSymbolIndex++;
        if (currentSymbolIndex >= tape.length) {
          tape.add('_');
        }
      } else {
        currentSymbolIndex--;
        if (currentSymbolIndex < 0) {
          tape.insert(0, '_');
          currentSymbolIndex = 0;
        }
      }
      currentState = currentTransition.nextState;
      currentSymbol = tape[currentSymbolIndex];
      currentTransition = transitions.firstWhereOrNull(
        (transition) =>
            transition.currentState == currentState &&
            transition.currentSymbol == currentSymbol,
      );
    }
    return acceptanceStates.contains(currentState);
  }

  (TuringState? state, List<String> tape, int headPosition) nextStep(
    TuringState state,
    List<String> tape,
    int headPosition,
  ) {
    var currentSymbol = tape[headPosition];
    TuringTransition? currentTransition = transitions.firstWhereOrNull(
      (transition) =>
          transition.currentState == state &&
          transition.currentSymbol == currentSymbol,
    );
    if (currentTransition == null) {
      return (null, tape, headPosition);
    }
    tape[headPosition] = currentTransition.newSymbol;
    if (currentTransition.direction == 'R') {
      headPosition++;
      if (headPosition >= tape.length) {
        tape.add('_');
      }
    } else {
      headPosition--;
      if (headPosition < 0) {
        tape.insert(0, '_');
        headPosition = 0;
      }
    }
    return (currentTransition.nextState, tape, headPosition);
  }

  String toDOT(TuringState? currentState, List<String> tape, int headPosition) {
    final sb = StringBuffer();
    sb.writeln('digraph {');
    sb.writeln('rankdir=LR;');
    sb.writeln('node [shape = circle];');
    for (final state in states) {
      sb.writeln('$state [label = "$state"];');
    }
    sb.writeln('node [shape = plaintext];');
    sb.writeln(
        '"" [label = <<table border="0" cellborder="1" cellspacing="0">');
    sb.writeln('<tr>');
    for (var i = 0; i < tape.length; i++) {
      if (i == headPosition) {
        sb.writeln('<td bgcolor="lightblue">${tape[i]}</td>');
      } else {
        sb.writeln('<td>${tape[i]}</td>');
      }
    }
    sb.writeln('</tr>');
    sb.writeln('</table>>];');
    sb.writeln('node [shape = circle];');
    for (final transition in transitions) {
      if (transition.currentState == currentState) {
        sb.writeln(
            '${transition.currentState} -> ${transition.nextState} [label = "${transition.currentSymbol} / ${transition.newSymbol}, ${transition.direction}", color = red];');
      } else {
        sb.writeln(
            '${transition.currentState} -> ${transition.nextState} [label = "${transition.currentSymbol} / ${transition.newSymbol}, ${transition.direction}"];');
      }
    }
    sb.writeln('}');
    return sb.toString();
  }

  String toJson() {
    final jsonMap = <String, dynamic>{};
    jsonMap['s'] = states.map((state) => state.name).toList();
    jsonMap['a'] = tapeAlphabet.toList();
    jsonMap['i'] = inputAlphabet.toList();
    jsonMap['d'] = <String, dynamic>{};
    for (final transition in transitions) {
      jsonMap['d'][transition.currentState.name.toString()] ??= {};
      jsonMap['d'][transition.currentState.name.toString()]
          [transition.currentSymbol] ??= [];
      jsonMap['d'][transition.currentState.name.toString()]
              [transition.currentSymbol]
          .add(transition.nextState.name);
      jsonMap['d'][transition.currentState.name.toString()]
              [transition.currentSymbol]
          .add(transition.newSymbol);
      jsonMap['d'][transition.currentState.name.toString()]
              [transition.currentSymbol]
          .add(transition.direction);
    }
    jsonMap['s_0'] = initialState.name;
    jsonMap['s_a'] = acceptanceStates.map((state) => state.name).toList();
    return jsonEncode(jsonMap);
  }

  factory TuringMachine.fromJson(String json) {
    final jsonMap = jsonDecode(json);
    final states = (jsonMap['s'] as List<dynamic>)
        .map((state) => TuringState(state as int))
        .toSet();
    final tapeAlphabet = (jsonMap['a'] as List<dynamic>)
        .map((symbol) => symbol as String)
        .toSet();
    final inputAlphabet = (jsonMap['i'] as List<dynamic>)
        .map((symbol) => symbol as String)
        .toSet();
    final transitions = <TuringTransition>[];
    for (final currentState in states) {
      for (final currentSymbol in tapeAlphabet) {
        if (jsonMap['d'][currentState.name.toString()] == null) {
          continue;
        }
        if (jsonMap['d'][currentState.name.toString()][currentSymbol] == null) {
          continue;
        }
        final nextState = TuringState(
          jsonMap['d'][currentState.name.toString()][currentSymbol][0] as int,
        );
        final newSymbol = jsonMap['d'][currentState.name.toString()]
            [currentSymbol][1] as String;
        final direction = jsonMap['d'][currentState.name.toString()]
            [currentSymbol][2] as String;
        transitions.add(
          TuringTransition(
            currentState: currentState,
            currentSymbol: currentSymbol,
            nextState: nextState,
            newSymbol: newSymbol,
            direction: direction,
          ),
        );
      }
    }
    final initialState = TuringState(jsonMap['s_0'] as int);
    final acceptanceStates = (jsonMap['s_a'] as List<dynamic>)
        .map((state) => TuringState(state as int))
        .toSet();
    return TuringMachine(
      states: states,
      tapeAlphabet: tapeAlphabet,
      inputAlphabet: inputAlphabet,
      transitions: transitions,
      initialState: initialState,
      acceptanceStates: acceptanceStates,
    );
  }
}
