import 'dart:convert';

class NFA {
  final Set<int> states;
  final Set<String> alphabet;
  final Map<int, Map<String, Set<int>>> transitions;
  final int initialState;
  final Set<int> finalStates;

  NFA({
    required this.states,
    required this.alphabet,
    required this.transitions,
    required this.initialState,
    required this.finalStates,
  });

  bool evaluateString(String input) {
    Set<int> currentStates = {initialState};

    for (var symbol in input.split('')) {
      if (!alphabet.contains(symbol)) {
        return false;
      }

      var nextStates = <int>{};
      for (var state in currentStates) {
        if (transitions.containsKey(state) &&
            transitions[state]!.containsKey(symbol)) {
          nextStates.addAll(transitions[state]![symbol]!);
        }
      }

      if (nextStates.isEmpty) {
        return false;
      }

      currentStates = nextStates;
    }

    return currentStates.any((state) => finalStates.contains(state));
  }

  Set<int> nextStates(Set<int> currentStates, String symbol) {
    var nextStates = <int>{};

    for (var state in currentStates) {
      final transitionsForState = transitions[state];
      if (transitionsForState == null) {
        continue;
      }

      // if transactionsForState contains epsilon, add all the epsilon transitions
      if (transitionsForState.containsKey('ε')) {
        nextStates.addAll(transitionsForState['ε']!);
      }
      final nextStatesForSymbol = transitionsForState[symbol];
      if (nextStatesForSymbol == null) {
        continue;
      }

      nextStates.addAll(nextStatesForSymbol);
    }

    return nextStates;
  }

  factory NFA.fromJson(String jsonString) {
    // {
    //   "s": [0, 1],
    //   "a": ["0", "1"],
    //   "d": {
    //     "0": {"0": [0], "1": [1]},
    //     "1": {"0": [1], "1": [1]}
    //   },
    //   "s_0": 0,
    //   "s_f": [1]
    // }
    final jsonMap = json.decode(jsonString);

    final Set<int> states = Set<int>.from(jsonMap['s'].map((e) {
      if (e is String) {
        return int.parse(e);
      }
      return e;
    }));
    final Set<String> alphabet = Set<String>.from(jsonMap['a']);
    final transitions = <int, Map<String, Set<int>>>{};

    jsonMap['d'].forEach((key, value) {
      transitions[int.parse(key)] =
          Map<String, Set<int>>.from(value.map((k, v) {
        if (v is String) {
          return MapEntry(k, {int.parse(v)});
        }
        return MapEntry(k, Set<int>.from(v));
      }));
    });

    late int initialState;
    if (jsonMap['s_0'] is String) {
      initialState = int.parse(jsonMap['s_0']);
    } else {
      initialState = jsonMap['s_0'];
    }
    final Set<int> finalStates = Set<int>.from(jsonMap['f_s'].map((e) {
      if (e is String) {
        return int.parse(e);
      }
      return e;
    }));

    return NFA(
      states: states,
      alphabet: alphabet,
      transitions: transitions,
      initialState: initialState,
      finalStates: finalStates,
    );
  }

  String toDOT(Set<int>? currentStates) {
    final buffer = StringBuffer();

    buffer.writeln('digraph NFA {');
    buffer.writeln('rankdir=LR;');
    buffer.writeln('node [shape = circle];');

    for (var state in states) {
      // Marking final states
      bool isFinalState = finalStates.contains(state);
      bool isCurrentState =
          currentStates != null && currentStates.contains(state);

      buffer.writeln(
          'q$state [shape = ${isFinalState ? 'doublecircle' : 'circle'}${isCurrentState ? ', color = green, style = filled' : ', color = black'}];');
    }

    buffer.writeln('qi [shape = point];'); // Start point
    buffer.writeln(
        'qi -> q$initialState;'); // Transition from start point to initial state

    // Transitions
    transitions.forEach((state, symbolMap) {
      symbolMap.forEach((symbol, nextStates) {
        for (final nextState in nextStates) {
          buffer.writeln('q$state -> q$nextState [label = "$symbol"];');
        }
      });
    });

    buffer.writeln('}');

    return buffer.toString();
  }
}
