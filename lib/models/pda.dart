import 'dart:convert';

import 'package:equatable/equatable.dart';

class PDAState extends Equatable {
  final int name;

  const PDAState(this.name);

  @override
  String toString() => 'q$name';

  @override
  List<Object?> get props => [name];
}

class PDATransition extends Equatable {
  final PDAState currentState;
  final String inputSymbol;
  final String stackSymbol;
  final PDAState nextState;

  /// `newStackSymbol` representa la operación que se realiza en la pila
  /// como resultado de la transición del autómata de pila.
  ///
  /// En cada transición, el autómata puede modificar la pila de las siguientes maneras:
  /// - Si `newStackSymbol` es una cadena vacía o contiene el símbolo especial 'ε',
  ///   indica que se debe eliminar el símbolo superior de la pila (operación POP).
  /// - Si `newStackSymbol` contiene uno o más símbolos, estos se empujarán a la pila.
  ///   Los símbolos se empujan en el orden en que aparecen en la cadena, por lo que el último
  ///   símbolo de la cadena será el nuevo símbolo superior de la pila (operación PUSH).
  /// - Si no se requiere ninguna modificación en la pila, `newStackSymbol` puede contener
  ///   el mismo símbolo que el símbolo de pila actual de la transición.
  ///
  /// Este enfoque permite representar de manera compacta y precisa las operaciones de pila
  /// que son fundamentales para la funcionalidad del autómata de pila, manteniendo la fidelidad
  /// con la definición formal de PDAs.

  final String newStackSymbol;

  const PDATransition({
    required this.currentState,
    required this.inputSymbol,
    required this.stackSymbol,
    required this.nextState,
    required this.newStackSymbol,
  });

  @override
  String toString() {
    return '($currentState, $inputSymbol, $stackSymbol) -> ($nextState, $newStackSymbol)';
  }

  @override
  List<Object?> get props => [
        currentState,
        inputSymbol,
        stackSymbol,
        nextState,
        newStackSymbol,
      ];
}

class PDA {
  final Set<PDAState> states;
  final Set<String> inputAlphabet;
  final Set<String> stackAlphabet;
  final List<PDATransition> transitions;
  final PDAState initialState;
  final String initialStackSymbol;
  final Set<PDAState> acceptanceStates;

  PDA({
    required this.states,
    required this.inputAlphabet,
    required this.stackAlphabet,
    required this.transitions,
    required this.initialState,
    required this.initialStackSymbol,
    required this.acceptanceStates,
  });

  // Método para analizar una cadena
  bool evaluateString(String input) {
    // Implementación inicial: asumimos PDA determinista para simplificar
    var currentState = initialState;
    var stack = [initialStackSymbol];

    for (var symbol in input.split('')) {
      bool transitionFound = false;
      for (var transition in transitions) {
        if (transition.currentState == currentState &&
            transition.inputSymbol == symbol &&
            stack.last == transition.stackSymbol) {
          currentState = transition.nextState;
          stack.removeLast();
          if (transition.newStackSymbol != '') {
            stack.addAll(transition.newStackSymbol.split('').reversed);
          }
          transitionFound = true;
          break;
        }
      }
      if (!transitionFound) return false;
    }

    return acceptanceStates.contains(currentState) && stack.isEmpty;
  }

  bool isFinalState(PDAState state) {
    return acceptanceStates.contains(state);
  }

  (Set<PDAState> nextStates, List<String> newStack) nextStates(
      Set<PDAState> currentStates,
      String inputSymbol,
      List<String> currentStack) {
    final nextStates = <PDAState>{};
    final newStackSymbols = <String>[...currentStack];
    for (final currentState in currentStates) {
      final currentStateTransitions = transitions.where((transition) =>
          transition.currentState == currentState &&
          transition.inputSymbol == inputSymbol &&
          transition.stackSymbol == currentStack.last);
      for (final transition in currentStateTransitions) {
        nextStates.add(transition.nextState);
        final currentStackSymbol = newStackSymbols.last;
        if (transition.newStackSymbol == 'ε' ||
            transition.newStackSymbol.isEmpty) {
          newStackSymbols.removeLast();
        }
        //  iterate over the newStackSymbol and add each symbol to the stack, if the first symbol of transition.newStackSymbol is the same as the top of the stack, ignore it
        else {
          String newStackSymbolToAnalyse = transition.newStackSymbol;
          if (newStackSymbolToAnalyse[0] == currentStackSymbol) {
            newStackSymbolToAnalyse = newStackSymbolToAnalyse.substring(1);
          }
          for (final symbol in newStackSymbolToAnalyse.split('').reversed) {
            newStackSymbols.add(symbol);
          }
        }
      }
    }
    return (nextStates, newStackSymbols);
  }

  String toDOT(Set<PDAState>? currentStates) {
    final buffer = StringBuffer();

    buffer.writeln('digraph PDA {');
    buffer.writeln('rankdir=LR;');
    buffer.writeln('node [shape = circle];');

    for (var state in states) {
      // Marking final states
      bool isFinalState = acceptanceStates.contains(state);
      bool isCurrentState =
          currentStates != null && currentStates.contains(state);

      buffer.writeln(
          '$state [shape = ${isFinalState ? 'doublecircle' : 'circle'}${isCurrentState ? ', color = green, style = filled' : ', color = black'}];');
    }

    buffer.writeln('qi [shape = point];'); // Start point
    buffer.writeln(
        'qi -> $initialState;'); // Transition from start point to initial state

    // Transitions
    for (final transition in transitions) {
      buffer.writeln(
          '${transition.currentState} -> ${transition.nextState} [label = "${transition.inputSymbol}, ${transition.stackSymbol} -> ${transition.newStackSymbol}"];');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  // create a to json method, try to use as less characters as possible
  String toJson() {
    final jsonMap = <String, dynamic>{};
    jsonMap['s'] = states.map((state) => state.name).toList();
    jsonMap['a'] = inputAlphabet.toList();
    jsonMap['g'] = stackAlphabet.toList();
    jsonMap['d'] = <String, dynamic>{};
    for (final transition in transitions) {
      jsonMap['d'][transition.currentState.name.toString()] ??= {};
      jsonMap['d'][transition.currentState.name.toString()]
          [transition.inputSymbol] ??= {};
      jsonMap['d'][transition.currentState.name.toString()]
          [transition.inputSymbol][transition.stackSymbol] ??= [];
      jsonMap['d'][transition.currentState.name.toString()]
              [transition.inputSymbol][transition.stackSymbol]
          .add(transition.nextState.name);
      jsonMap['d'][transition.currentState.name.toString()]
              [transition.inputSymbol][transition.stackSymbol]
          .add(transition.newStackSymbol);
    }
    jsonMap['s_0'] = initialState.name;
    jsonMap['g_0'] = initialStackSymbol;
    jsonMap['f_s'] = acceptanceStates.map((state) => state.name).toList();
    jsonMap['t'] = 'pda';
    return jsonEncode(jsonMap);
  }

  // create a from json method
  factory PDA.fromJson(String json) {
    // based on the implementation of the to json method do the inverse
    final jsonMap = jsonDecode(json) as Map<String, dynamic>;
    final states = (jsonMap['s'] as List<dynamic>)
        .map((state) => PDAState(state as int))
        .toSet();
    final inputAlphabet =
        (jsonMap['a'] as List<dynamic>).map((e) => e as String).toSet();
    final stackAlphabet =
        (jsonMap['g'] as List<dynamic>).map((e) => e as String).toSet();
    final transitions = <PDATransition>[];

    final jsonTransitions = jsonMap['d'] as Map<String, dynamic>;
    for (final currentStateName in jsonTransitions.keys) {
      final currentState = PDAState(int.parse(currentStateName));
      final jsonCurrentStateTransitions =
          jsonTransitions[currentStateName] as Map<String, dynamic>;
      for (final inputSymbol in jsonCurrentStateTransitions.keys) {
        final jsonInputSymbolTransitions =
            jsonCurrentStateTransitions[inputSymbol] as Map<String, dynamic>;
        for (final stackSymbol in jsonInputSymbolTransitions.keys) {
          final jsonStackSymbolTransitions =
              jsonInputSymbolTransitions[stackSymbol] as List<dynamic>;
          for (var i = 0; i < jsonStackSymbolTransitions.length; i += 2) {
            final nextState = PDAState(jsonStackSymbolTransitions[i] as int);
            final newStackSymbol = jsonStackSymbolTransitions[i + 1] as String;
            transitions.add(
              PDATransition(
                currentState: currentState,
                inputSymbol: inputSymbol,
                stackSymbol: stackSymbol,
                nextState: nextState,
                newStackSymbol: newStackSymbol,
              ),
            );
          }
        }
      }
    }

    final initialState = PDAState(jsonMap['s_0'] as int);
    final acceptanceStates = (jsonMap['f_s'] as List<dynamic>)
        .map((state) => PDAState(state as int))
        .toSet();

    return PDA(
      states: states,
      inputAlphabet: inputAlphabet,
      stackAlphabet: stackAlphabet,
      transitions: transitions,
      initialState: initialState,
      initialStackSymbol: 'Z0', // TODO: Make this configurable
      acceptanceStates: acceptanceStates,
    );
  }
}
