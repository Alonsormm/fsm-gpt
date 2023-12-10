import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/pages/automatico/cubit/automatico_flow_cubit.dart';

class InteractingStep extends StatefulWidget {
  const InteractingStep({super.key});

  @override
  State<InteractingStep> createState() => _InteractingStepState();
}

class _InteractingStepState extends State<InteractingStep> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final interactingState =
        context.watch<AutomaticoFlowCubit>().state as AutomaticoFlowInteracting;
    final type = interactingState.type;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<AutomaticoFlowCubit, AutomaticoFlowState>(
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Crea un ${type.label} que: '),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Escriba una expresión regular',
                  ),
                  controller: textController,
                  onChanged: (value) {
                    context
                        .read<AutomaticoFlowCubit>()
                        .updateDescription(value);
                  },
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AutomaticoFlowCubit>().generate();
                  },
                  child: const Text('Crear'),
                ),
                const SizedBox(height: 16),
                if (interactingState.isLoading)
                  const CircularProgressIndicator(),
                if (interactingState is AutomaticoFlowError)
                  Text(interactingState.message),
              ],
            );
          },
        ),
      ),
    );
  }
}
