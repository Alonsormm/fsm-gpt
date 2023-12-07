import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/pages/manual/cubit/manual_flow_cubit.dart';
import 'package:fsm_gpt/pages/manual/steps/automata_type_step.dart';
import 'package:fsm_gpt/pages/manual/steps/interacting_step.dart';
import 'package:kartal/kartal.dart';

class ManualPage extends StatelessWidget {
  const ManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "MEF GPT - Manual",
            style: context.general.textTheme.titleLarge,
          ),
        ),
        body: BlocProvider<ManualFlowCubit>(
          create: (context) => ManualFlowCubit(),
          child: const _ManualFlowDisplay(),
        ));
  }
}

class _ManualFlowDisplay extends StatelessWidget {
  const _ManualFlowDisplay();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManualFlowCubit, ManualFlowState>(
        builder: (context, state) {
      return _currentStep(state);
    });
  }

  Widget _currentStep(ManualFlowState state) {
    if (state is ManualFlowStateSelectingType) return const AutomataTypeStep();
    if (state is ManualFlowStateInteracting) return const InteractingStep();
    return const SizedBox.shrink();
  }
}
