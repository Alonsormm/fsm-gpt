import 'dart:convert';

import 'package:equatable/equatable.dart';

class PdaState extends Equatable {
  final int name;

  const PdaState(this.name);

  @override
  String toString() => 'q$name';

  @override
  List<Object?> get props => [name];
}

class PdaTransition extends Equatable {
  final PdaState currentState;
  final String inputSymbol;
  final String stackSymbol;
  final PdaState nextState;

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

  const PdaTransition({
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

class PushdownAutomaton {
  final Set<PdaState> states;
  final Set<String> inputAlphabet;
  final Set<String> stackAlphabet;
  final List<PdaTransition> transitions;
  final PdaState initialState;
  final String initialStackSymbol;
  final Set<PdaState> acceptanceStates;

  PushdownAutomaton({
    required this.states,
    required this.inputAlphabet,
    required this.stackAlphabet,
    required this.transitions,
    required this.initialState,
    required this.initialStackSymbol,
    required this.acceptanceStates,
  });

  // Método para analizar una cadena
  bool analyzeString(String input) {
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

  bool isFinalState(PdaState state) {
    return acceptanceStates.contains(state);
  }

  (Set<PdaState> nextStates, List<String> newStack) nextStates(
      Set<PdaState> currentStates,
      String inputSymbol,
      List<String> currentStack) {
    final nextStates = <PdaState>{};
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

  String toDOT(Set<PdaState>? currentStates) {
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
    return jsonEncode(jsonMap);
  }

  // create a from json method
  factory PushdownAutomaton.fromJson(String json) {
    // based on the implementation of the to json method do the inverse
    final jsonMap = jsonDecode(json) as Map<String, dynamic>;
    final states = (jsonMap['s'] as List<dynamic>)
        .map((state) => PdaState(state as int))
        .toSet();
    final inputAlphabet =
        (jsonMap['a'] as List<dynamic>).map((e) => e as String).toSet();
    final stackAlphabet =
        (jsonMap['g'] as List<dynamic>).map((e) => e as String).toSet();
    final transitions = <PdaTransition>[];

    for (final currentState in states) {
      for (final inputSymbol in inputAlphabet) {
        for (final stackSymbol in stackAlphabet) {
          final transition = jsonMap['d']?[currentState.name.toString()]
              ?[inputSymbol]?[stackSymbol];
          if (transition == null) continue;
          final nextState = PdaState(jsonMap['d'][currentState.name.toString()]
              [inputSymbol]![stackSymbol][0] as int);
          final newStackSymbol = jsonMap['d'][currentState.name.toString()]
              [inputSymbol]![stackSymbol][1] as String;
          transitions.add(PdaTransition(
            currentState: currentState,
            inputSymbol: inputSymbol,
            stackSymbol: stackSymbol,
            nextState: nextState,
            newStackSymbol: newStackSymbol,
          ));
        }
      }
    }

    final initialState = PdaState(jsonMap['s_0'] as int);
    final initialStackSymbol = jsonMap['g_0'] as String;
    final acceptanceStates = (jsonMap['f_s'] as List<dynamic>)
        .map((state) => PdaState(state as int))
        .toSet();

    return PushdownAutomaton(
      states: states,
      inputAlphabet: inputAlphabet,
      stackAlphabet: stackAlphabet,
      transitions: transitions,
      initialState: initialState,
      initialStackSymbol: initialStackSymbol,
      acceptanceStates: acceptanceStates,
    );
  }
}