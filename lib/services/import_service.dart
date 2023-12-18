import 'dart:convert';

import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/models/nfa.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/models/turning_machine.dart';

class ImportService {
  Future<dynamic> importJson(String json) async {
    final decodedJson = jsonDecode(json);
    if (decodedJson['t'] == 'nfa') {
      return NFA.fromJson(json);
    } else if (decodedJson['t'] == 'dfa') {
      return DFA.fromJson(json);
    } else if (decodedJson['t'] == 'turing') {
      return TuringMachine.fromJson(json);
    } else if (decodedJson['t'] == 'pda') {
      return PDA.fromJson(json);
    } else {
      throw Exception('Invalid type');
    }
  }
}
