import 'package:fsm_gpt/enums/fsm_type.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/models/nfa.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
import 'package:fsm_gpt/services/open_ai_service.dart';

class FSMFromTextService {
  static const dfaInstructions = '''
  creeate an deterministic finite automaton.
  The JSON keys are:
  s: states (list of integers)
  f_s: final states (list of integers)
  s_0: initial state (integer)
  a: alphabet (list of strings)
  d: transitions (dictionary of dictionaries, the key of the first dictionary are the states (integers) and the key of the second dictionary are the alphabet (strings), the value of the second dictionary are the next states (list of integers))
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  remember that if after analize the input string the automata is in a final state, the string is accepted
  add the less states possible
  ''';

  static const nfaInstructions = '''
  create an non deterministic finite automaton.
  The JSON keys are:
  s: states (list of integers)
  f_s: final states (list of integers)
  s_0: initial state (integer)
  a: alphabet (list of strings)
  d: transitions (dictionary of dictionaries, where the states are list of integers and the alphabet are strings)
  example of transitions:
  {
    "0": {
      "0": [0, 1],
      "1": [0]
    },
    "1": {
      "0": [2],
      "1": [2]
    },
    "2": {
      "0": [2],
      "1": [2]
    }
  }
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  remember that if after analize the input string the automata is in a final state, the string is accepted
  add the less states possible
  ''';

  // '{"s":[0,1,2],"a":["ε","a","b"],"g":["Z0","ε","A"],"d":{"0":{"a":{"Z0":[0,"A"],"A":[0,"AA"]},"b":{"A":[1,"ε"]}},"1":{"b":{"A":[1,"ε"]},"ε":{"Z0":[2,"ε"]}}},"s_0":0,"g_0":"","f_s":[2]}');

  static const pushdownAutomataFormatInstructions = '''
  create an pushdown automaton.
  The JSON keys are:
  s: states (list of integers)
  f_s: final states (list of integers)
  s_0: initial state (integer)
  a: alphabet (list of strings)
  g: stack alphabet (list of strings)
  d: transitions (dictionary of dictionaries, where the states are list of integers and the alphabet are strings)
  // example: {"s":[0,1,2],"a":["ε","a","b"],"g":["Z0","ε","A"],"d":{"0":{"a":{"Z0":[0,"A"],"A":[0,"AA"]},"b":{"A":[1,"ε"]}},"1":{"b":{"A":[1,"ε"]},"ε":{"Z0":[2,"ε"]}}},"s_0":0,"g_0":"","f_s":[2]}
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  remember that if after analize the input string the automata is in a final state, the string is accepted
  add the less states possible
  ''';

  static const turingFormatInstructions = '''
  create an turing machine.
  The JSON keys are:
  s: states (list of integers)
  a_s: final states (list of integers)
  s_0: initial state (integer)
  a: alphabet (list of strings)
  i: input alphabet (list of strings)
  d: transitions (dictionary of dictionaries, where the states are list of integers and the alphabet are strings)
  example: {"s":[0,1,2],"a":["_","0","1"],"i":["_","0","1"],"d":{"0":{"0":[0,"0","R"],"1":[1,"1","R"],"_":[2,"_","R"]},"1":{"0":[1,"0","R"],"1":[0,"1","R"],"_":[1,"_","R"]}},"s_0":0,"s_a":[2]}
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  remember that if after analize the input string the automata is in a final state, the string is accepted
  add the less states possible
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

    return (DFA.fromJson(jsonString), jsonString);
  }

  static Future<(NFA nfa, String jsonString)> generateNFAFromText(
    String text,
  ) async {
    final jsonString = await OpenAIService.generateTextFromPrompt(
        getInstructions(FSMType.nfa), text);

    return (NFA.fromJson(jsonString), jsonString);
  }

  static Future<(PDA pda, String jsonString)> generatePDAFromText(
    String text,
  ) async {
    final jsonString = await OpenAIService.generateTextFromPrompt(
        getInstructions(FSMType.pda), text);

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
