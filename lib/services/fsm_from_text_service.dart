import 'package:fsm_gpt/enums/fsm_type.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/models/nfa.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
import 'package:fsm_gpt/services/open_ai_service.dart';

class FSMFromTextService {
  static const dfaInstructions = '''
    un automata finito determinista en un json en el que
    s es la lista de estados, los estados son enteros
    a es el alfabeto de entrada, una lista de cadenas
    d es un mapa de estados a un mapa de símbolos de entrada a una lista de estados
    por ejemplo "2": {"0": 1} significa que si estas en el estado 2 y recibes un 0 te mueves al estado 1
    s_0 es el estado inicial, es un entero
    f_s es la lista de estados de aceptación, lista de enteros
    asegurate que siempre se puede llegar a un estado de aceptación
    y usa el menor numero de estados posibles
  ''';

  static const nfaInstructions = '''
    un automata finito no determinista en un json en el que
    s es la lista de estados, los estados son enteros
    a es el alfabeto de entrada, una lista de cadenas
    d es un mapa de estados a un mapa de símbolos de entrada a una lista de estados
    por ejemplo "2": {"0": [1]} significa que si estas en el estado 2 y recibes un 0 te mueves al estado 1
    s_0 es el estado inicial, es un entero
    f_s es la lista de estados de aceptación, lista de enteros
    asegurate que siempre se puede llegar a un estado de aceptación
    y usa el menor numero de estados posibles
  ''';

  // '{"s":[0,1,2],"a":["ε","a","b"],"g":["Z0","ε","A"],"d":{"0":{"a":{"Z0":[0,"A"],"A":[0,"AA"]},"b":{"A":[1,"ε"]}},"1":{"b":{"A":[1,"ε"]},"ε":{"Z0":[2,"ε"]}}},"s_0":0,"g_0":"","f_s":[2]}');

  static const pushdownAutomataFormatInstructions = '''
    un automata de pila en un json en el que
    
    s es la lista de estados, los estados son enteros
    
    a es el alfabeto de entrada, una lista de cadenas
    
    g es el alfabeto de la pila, este alfabeto incluye el simbolo vacio "ε" y el simbolo de la pila vacia "Z0"
    puedes usar los simbolos que quieras para el alfabeto de entrada pero regularmente se usan A, B, C, etc.
    por ejemplo: ["ε", "z0", "A", "B", "C"]
    y los simbolos que sean necesarios para las transiciones, recuerda que el alfabeto de pila es diferente al alfabeto de entrada.
    
    d es un mapa de estados, en donde se tiene el siguiente formato:
    en donde la key es el estado actual, luego el value de este key es un nuevo json
    este nuevo json tiene como keys los simbolos de la pila, y como value un nuevo json
    este nuevo json tiene como keys los simbolos de entrada, y como value una lista de 2 elementos
    el primer elemento de la lista es el nuevo estado, y el segundo elemento es el nuevo simbolo de la pila
    el nuevo simbolo de la pila sigue las siguientes reglas: 
    sea cual sea el simbolo actual de la pila, si el nuevo simbolo de la pila es "ε" entonces se saca un simbolo de la pila
    si el nuevo simbolo de la pila es "A" y el simbolo actual de la pila es "A" entonces no se hace nada
    si el nuevo simbolo de la pila es "AA" y el simbolo actual de la pila es "A" entonces se mete una "A" a la pila
    entonces si estas en z0 y quieres meter una A a la pila, entonces el nuevo simbolo de la pila es "A"
    por ejemplo "0": {"A": {"1": [0, "A"] } }, en donde se lee como "si estoy en el estado 0 y el tope de la pila es A y recibo un 1 entonces me muevo al estado 0 y saco un A de la pila"
    
    s_0 es el estado inicial, es un entero
    f_s es la lista de estados de aceptación, lista de enteros
    donde el simbolo vacio siempre es "ε", y el simbolo de la pila vacia es "Z0"
    siguiendo la notacion si el simbolo de la pila es "ε" entonces se saca un simbolo de la pila
    si el simbolo de la pila es "A" y la transicion es "A" entonces no se hace nada
    si el simbolo de la pila es "A" y la transicion es "AA" entonces se mete una "A" a la pila
    asegurate que siempre se puede llegar a un estado de aceptación
    y usa el menor numero de estados posibles
  ''';

  static const turingFormatInstructions = '''
    una maquina de turing en un json en el que
    s es la lista de estados, los estados son enteros
    i es el alfabeto de entrada, una lista de cadenas
    a es el alfabeto de la cinta, una lista de cadenas
    d es un mapa de estados a un mapa de símbolos de entrada a una lista de estados, si los estados son keys entonces ponlos como string, si no, como enteros, si vas a moverte a la derecha usa R, sino L y si no te mueves usa S
    las transiciones son una lista de 3 cosas [nuevo estado, nuevo simbolo, movimiento]
    s_0 es el estado inicial, es un entero
    s_a es la lista de estados de aceptación, lista de enteros
    donde el simbolo vacio siempre es "_"
    asegurate que siempre se puede llegar a un estado de aceptación
    y usa el menor numero de estados posibles
  ''';

  static String getInstructions(FSMType type) {
    switch (type) {
      case FSMType.dfa:
        return dfaInstructions;
      case FSMType.nfa:
        return nfaInstructions;
      case FSMType.pda:
        return pushdownAutomataFormatInstructions;
      case FSMType.turing:
        return turingFormatInstructions;
    }
  }

  static Future<(DFA dfa, String jsonString)> generateDFAFromText(
    String text,
  ) async {
    final jsonString = await OpenAIService.generateTextFromPrompt(
        getInstructions(FSMType.dfa), text);

    print(jsonString);

    return (DFA.fromJson(jsonString), jsonString);
  }

  static Future<(NFA nfa, String jsonString)> generateNFAFromText(
    String text,
  ) async {
    final jsonString = await OpenAIService.generateTextFromPrompt(
        getInstructions(FSMType.nfa), text);

    print(jsonString);

    return (NFA.fromJson(jsonString), jsonString);
  }

  static Future<(PDA pda, String jsonString)> generatePDAFromText(
    String text,
  ) async {
    final jsonString = await OpenAIService.generateTextFromPrompt(
        getInstructions(FSMType.pda), text);

    print(jsonString);

    return (PDA.fromJson(jsonString), jsonString);
  }

  static Future<(TuringMachine turingMachine, String jsonString)>
      generateTuringMachineFromText(
    String text,
  ) async {
    final jsonString = await OpenAIService.generateTextFromPrompt(
        getInstructions(FSMType.turing), text);

    return (TuringMachine.fromJson(jsonString), jsonString);
  }
}
