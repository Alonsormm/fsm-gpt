import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/enums/fsm_type.dart';
import 'package:fsm_gpt/pages/automatico/cubit/automatico_flow_cubit.dart';
import 'package:fsm_gpt/pages/automatico/steps/automata_type_step.dart';
import 'package:fsm_gpt/pages/automatico/steps/interacting_step.dart';
import 'package:fsm_gpt/pages/dfa_tester/dfa_tester_screen.dart';
import 'package:fsm_gpt/pages/manual/turing_machine_tester.dart/turing_machine_tester_screen.dart';
import 'package:fsm_gpt/pages/nfa_tester/nfa_tester_screen.dart';
import 'package:fsm_gpt/pages/pda_tester/pda_tester_screen.dart';
import 'package:kartal/kartal.dart';

class AutomaticoPage extends StatelessWidget {
  const AutomaticoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MEF GPT - Automatico",
          style: context.general.textTheme.titleLarge,
        ),
      ),
      body: BlocProvider<AutomaticoFlowCubit>(
        create: (context) => AutomaticoFlowCubit(),
        child: const _AutomaticoFlowDisplay(),
      ),
    );
  }
}

class _AutomaticoFlowDisplay extends StatelessWidget {
  const _AutomaticoFlowDisplay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutomaticoFlowCubit, AutomaticoFlowState>(
        builder: (context, state) {
      return _currentStep(state);
    });
  }

  Widget _currentStep(AutomaticoFlowState state) {
    if (state is AutomaticoFlowStateSelectingType) {
      return const AutomataTypeStep();
    }
    if (state is AutomaticoFlowInteracting) return const InteractingStep();
    if (state is AutomaticoGenerated) {
      switch (state.type) {
        case FSMType.dfa:
          return DFATesterScreen(
            dfa: state.dfa!,
            description: state.description,
          );
        case FSMType.nfa:
          return NFATesterScreen(
              nfa: state.nfa!, description: state.description);
        case FSMType.pda:
          return PDATesterScreen(
              pda: state.pda!, description: state.description);
        case FSMType.turing:
          return TuringMachineTesterScreen(
              turingMachine: state.turingMachine!,
              description: state.description);
        default:
          return const Text("NOT supported yet");
      }
    }
    return const SizedBox.shrink();
  }
}
