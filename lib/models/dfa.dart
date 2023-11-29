import 'dart:convert';

class DFA {
  final Set<int> states;
  final Set<String> alphabet;
  final Map<int, Map<String, int>> transitions;
  final int initialState;
  final Set<int> finalStates;

  DFA(
      {required this.states,
      required this.alphabet,
      required this.transitions,
      required this.initialState,
      required this.finalStates});

  bool evaluateString(String input) {
    int currentState = initialState;

    for (int i = 0; i < input.length; i++) {
      String symbol = input[i];

      if (!alphabet.contains(symbol)) {
        return false; // Reject if symbol is not in the alphabet
      }

      if (!transitions.containsKey(currentState) ||
          !transitions[currentState]!.containsKey(symbol)) {
        return false; // Reject if there is no transition for the current state and symbol
      }

      currentState = transitions[currentState]![symbol]!;
    }

    return finalStates.contains(currentState);
  }

  int? nextState(int currentState, String symbol) {
    if (!alphabet.contains(symbol)) {
      return null; // Reject if symbol is not in the alphabet
    }

    if (!transitions.containsKey(currentState) ||
        !transitions[currentState]!.containsKey(symbol)) {
      return null; // Reject if there is no transition for the current state and symbol
    }

    return transitions[currentState]![symbol];
  }

  factory DFA.fromJson(String jsonString) {
    final jsonMap = json.decode(jsonString);

    final Set<int> states = Set<int>.from(jsonMap['s'].map((e) => e));
    final Set<String> alphabet = Set<String>.from(jsonMap['a']);
    final transitions = <int, Map<String, int>>{};

    jsonMap['d'].forEach((key, value) {
      transitions[int.parse(key)] = Map<String, int>.from(value.map((k, v) {
        return MapEntry(k, v);
      }));
    });

    final int initialState = jsonMap['s_0'];
    final Set<int> finalStates = Set<int>.from(jsonMap['f_s'].map((e) => e));

    return DFA(
      states: states,
      alphabet: alphabet,
      transitions: transitions,
      initialState: initialState,
      finalStates: finalStates,
    );
  }

  String toDOT(int? currentState) {
    final buffer = StringBuffer();

    buffer.writeln('digraph DFA {');
    buffer.writeln('rankdir=LR;');
    buffer.writeln('node [shape = circle];');

    for (var state in states) {
      if (finalStates.contains(state)) {
        // drawed as double circle and fille as green if is current state
        if (currentState == state) {
          buffer.writeln(
              'q$state [shape = doublecircle, color = green, style = filled];');
        } else {
          buffer.writeln('q$state [shape = doublecircle, color = black];');
        }
      } else {
        if (currentState == state) {
          // fill color for current state
          buffer.writeln('q$state [color = green, style = filled];');
        } else {
          buffer.writeln('q$state [color = black];');
        }
      }
    }

    buffer.writeln('qi [shape = point];');
    buffer.writeln('qi -> q$initialState;');

    transitions.forEach((key, value) {
      value.forEach((symbol, nextState) {
        buffer.writeln('q$key -> q$nextState [label = "$symbol"];');
      });
    });

    buffer.writeln('}');

    return buffer.toString();
  }
}
