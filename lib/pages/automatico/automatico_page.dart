import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/pages/automatico/cubit/automatico_cubit.dart';
import 'package:fsm_gpt/pages/dfa_tester/dfa_tester_screen.dart';
import 'package:kartal/kartal.dart';

class AutomaticoPage extends StatelessWidget {
  const AutomaticoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "FSM GPT - Automático",
            style: context.general.textTheme.titleLarge,
          ),
        ),
        body: BlocProvider(
          create: (context) => AutomaticoCubit(),
          child: const _AutomaticoDisplay(),
        ));
  }
}

class _AutomaticoDisplay extends StatelessWidget {
  const _AutomaticoDisplay();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AutomaticoCubit, AutomaticoCubitState>(
      listener: (context, state) {
        if (state is AutomaticoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        }
        if (state is AutomaticoLoaded) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DFATesterScreen(
                dfa: state.dfa,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AutomaticoSettingUp) {
          return _AutomaticoSettingUpDisplay(
            description: state.description,
            onDescriptionChanged: (description) {
              context.read<AutomaticoCubit>().setDescription(description);
            },
            onContinuePressed: () {
              context.read<AutomaticoCubit>().loadDFA();
            },
          );
        }
        if (state is AutomaticoLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AutomaticoSettingUpDisplay extends StatelessWidget {
  final String? description;
  final ValueChanged<String> onDescriptionChanged;
  final VoidCallback onContinuePressed;
  const _AutomaticoSettingUpDisplay({
    required this.description,
    required this.onDescriptionChanged,
    required this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Crear un DFA que"),
          TextField(
            decoration: const InputDecoration(labelText: "Description"),
            onChanged: onDescriptionChanged,
          ),
          TextButton(
            onPressed: onContinuePressed,
            child: const Text("Continue"),
          )
        ],
      ),
    );
  }
}
