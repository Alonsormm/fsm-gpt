import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/enums/fsm_type.dart';
import 'package:fsm_gpt/pages/automatico/cubit/automatico_flow_cubit.dart';

class AutomataTypeStep extends StatelessWidget {
  const AutomataTypeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: FSMType.values.length,
      itemBuilder: (context, index) {
        final fsmType = FSMType.values[index];
        return ListTile(
          title: Text(fsmType.label),
          onTap: () {
            context.read<AutomaticoFlowCubit>().startInteracting(fsmType);
          },
        );
      },
    );
  }
}
