import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/enums/fsm_type.dart';
import 'package:fsm_gpt/pages/manual/cubit/manual_flow_cubit.dart';
import 'package:fsm_gpt/pages/manual/inputs/dfa_input.dart';
import 'package:fsm_gpt/pages/manual/inputs/nfa_input.dart';
import 'package:fsm_gpt/pages/manual/inputs/pda_input.dart';
import 'package:fsm_gpt/pages/manual/inputs/turing_machine_input.dart';

class InteractingStep extends StatelessWidget {
  const InteractingStep({super.key});

  @override
  Widget build(BuildContext context) {
    final type =
        (context.read<ManualFlowCubit>().state as ManualFlowStateInteracting)
            .type;
    switch (type) {
      case FSMType.dfa:
        return const DFACreator();
      case FSMType.nfa:
        return const NFACreator();
      case FSMType.pda:
        return const PDACreator();
      case FSMType.turing:
        return const TuringMachineCreator();
      default:
        return const Text("NOT supported yet");
    }
  }
}
