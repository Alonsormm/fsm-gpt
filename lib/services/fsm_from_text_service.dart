import 'package:fsm_gpt/enums/fsm_type.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/services/open_ai_service.dart';

class FSMFromTextService {
  static const automataFormatInstructions = '''
  with the next format: {"s":["0", "1", "2", etc],"f_s":["2"],"s_0":"0","a":["a","b"],"d":{"0":{"a":"1","b":"2"},"1":{"a":"1","b":"2"},"2":{"a":"2","b":"2"}}}
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  ''';

  static const dfaInstructions = '''
  create an deterministic finite automaton $automataFormatInstructions''';

  static const nfaInstructions = '''
  create an non deterministic finite automaton $automataFormatInstructions''';

  static const pushdownAutomataFormatInstructions = '''
  {"s":["0","1","2"],"i":["0","1"],"a":["0","1","_"],"t":{"0":{"0":{"p":"_","u":"0","n":"0"},"1":{"p":"_","u":"1","n":"1"}},"1":{"1":{"p":"0","u":"_","n":"2"}}},"r":"2","j":[]}
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  ''';

  static const pdaInstructions = '''
  create an pushdown automaton $pushdownAutomataFormatInstructions''';

  static const turingFormatInstructions = '''
  {"s":["0","1","2"],"i":["0","1"],"a":["0","1","_"],"t":{"0":{"0":{"p":"_","u":"0","n":"0"},"1":{"p":"_","u":"1","n":"1"}},"1":{"1":{"p":"0","u":"_","n":"2"}}},"r":"2","j":[]}
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  ''';

  static const turingInstructions = '''
  create an turing machine $turingFormatInstructions''';

  static const mealyMooreFormatInstructions = '''
  {"s":["0","1","2"],"i":["0","1"],"a":["0","1","_"],"t":{"0":{"0":{"p":"_","u":"0","n":"0"},"1":{"p":"_","u":"1","n":"1"}},"1":{"1":{"p":"0","u":"_","n":"2"}}},"r":"2","j":[]}
  please avoid spaces and line breaks in your answers, you can send a regular expresion for alphabet and states transitions
  ''';

  static const mealyInstructions = '''
  create an mealy machine $mealyMooreFormatInstructions''';

  static const mooreInstructions = '''
  create an moore machine $mealyMooreFormatInstructions''';

  static String getInstructions(FSMType type) {
    switch (type) {
      case FSMType.dfa:
        return dfaInstructions;
      case FSMType.nfa:
        return nfaInstructions;
      case FSMType.pda:
        return pdaInstructions;
      case FSMType.turing:
        return turingInstructions;
    }
  }

  static Future<DFA> generateDFAFromText(String text) async {
    final jsonString = await OpenAIService.generateTextFromPrompt(
      getInstructions(FSMType.dfa),
      text,
    );

    return DFA.fromJson(jsonString);
  }
}
