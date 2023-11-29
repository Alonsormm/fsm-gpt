import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/pages/pda_tester/pda_tester_cubit.dart'; // Asegúrate de que esta clase exista

class PDATesterScreen extends StatelessWidget {
  final PushdownAutomaton pda;
  final String? description;
  const PDATesterScreen({super.key, required this.pda, this.description});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PDATesterCubit(pda: pda),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("PDA Tester"),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PDAInfoDialog(
                    pda: pda,
                    description: description,
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        body: _PDATesterDisplay(pda: pda),
      ),
    );
  }
}

class _PDATesterDisplay extends StatelessWidget {
  final PushdownAutomaton pda;
  const _PDATesterDisplay({required this.pda});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<PDATesterCubit, PDATesterState>(
        builder: (context, currentCubitState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Input"),
                onChanged: (input) {
                  context.read<PDATesterCubit>().setInput(input);
                },
              ),
              _DelaySelector(
                currentCubitState: currentCubitState,
              ),
              Text("Evaluate Delay: ${currentCubitState.evaluateDelay}s"),
              if (currentCubitState is PDATesterEvaluating)
                _InputEvaluatorIndicator(
                  currentCubitState: currentCubitState,
                ),
              TextButton(
                onPressed: () {
                  if (currentCubitState is PDATesterEvaluating) {
                    context.read<PDATesterCubit>().reset();
                  } else {
                    context.read<PDATesterCubit>().startEvaluation();
                  }
                },
                child: Text(
                  currentCubitState is PDATesterEvaluating ? "Reset" : "Start",
                ),
              ),
              if (currentCubitState is PDATesterEvaluating) ...[
                Text(
                  "Current State: ${currentCubitState.currentStates.join(", ")}",
                ),
                Text(
                  "Current Stack: ${currentCubitState.stack}",
                ),
              ],
              if (currentCubitState is PDATesterEvaluating &&
                  currentCubitState.isFinished)
                Text(
                  "Result: ${currentCubitState.isAccepted ? "Accepted" : "Rejected"}",
                ),
              _pdaVisualizer(currentCubitState is PDATesterEvaluating
                  ? currentCubitState.currentStates
                  : null),
            ],
          );
        },
      ),
    );
  }

  Expanded _pdaVisualizer(Set<PdaState>? currentState) {
    return Expanded(
      child: CachedNetworkImage(
        imageUrl:
            'https://quickchart.io/graphviz?graph=${Uri.encodeComponent(pda.toDOT(currentState))}&format=png&engine=dot',
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _DelaySelector extends StatelessWidget {
  final PDATesterState currentCubitState;
  const _DelaySelector({
    required this.currentCubitState,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: currentCubitState.evaluateDelay,
      onChanged: currentCubitState is PDATesterSettingUp
          ? (double value) {
              context.read<PDATesterCubit>().setEvaluateDelay(value);
            }
          : null,
      divisions: 8,
      min: 2,
      max: 10,
    );
  }
}

class _InputEvaluatorIndicator extends StatelessWidget {
  final PDATesterEvaluating currentCubitState;
  const _InputEvaluatorIndicator({
    required this.currentCubitState,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: currentCubitState.input.length,
        itemBuilder: (context, index) {
          final symbol = currentCubitState.input[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(symbol),
                if (index == currentCubitState.currentInputIndex - 1)
                  const Icon(Icons.arrow_upward_outlined),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PDAInfoDialog extends StatelessWidget {
  final PushdownAutomaton pda;
  final String? description;
  const PDAInfoDialog({super.key, required this.pda, this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("PDA Info"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Description: ${description ?? "No description"}"),
          Text("States: ${pda.states.join(", ")}"),
          Text("Input Alphabet: ${pda.inputAlphabet.join(", ")}"),
          Text("Stack Alphabet: ${pda.stackAlphabet.join(", ")}"),
          Text("Initial State: ${pda.initialState}"),
          Text("Accepting States: ${pda.acceptanceStates.join(", ")}"),
          Text("Transitions:"),
          for (final transition in pda.transitions) Text(transition.toString()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
      ],
    );
  }
}
