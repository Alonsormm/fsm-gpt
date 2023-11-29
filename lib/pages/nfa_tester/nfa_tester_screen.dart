import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/models/nfa.dart'; // Asumiendo que esta clase existe
import 'package:fsm_gpt/pages/nfa_tester/nfa_tester_cubit.dart'; // Asumiendo que esta clase existe

class NFATesterScreen extends StatelessWidget {
  final NFA nfa;
  final String? description;
  const NFATesterScreen({super.key, required this.nfa, this.description});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NFATesterCubit(nfa: nfa),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NFA Tester"),
          actions: [
            IconButton(
              onPressed: () {
                showNFAInfoDialog(context, nfa, description: description);
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        body: _NFATesterDisplay(nfa: nfa),
      ),
    );
  }
}

class _NFATesterDisplay extends StatelessWidget {
  final NFA nfa;
  const _NFATesterDisplay({required this.nfa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<NFATesterCubit, NFATesterState>(
        builder: (context, currentCubitState) {
          Set<int>? currentStates;
          if (currentCubitState is NFATesterEvaluating) {
            currentStates = currentCubitState.currentStates;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Input"),
                onChanged: (input) {
                  context.read<NFATesterCubit>().setInput(input);
                },
              ),
              _DelaySelector(
                currentCubitState: currentCubitState,
              ),
              Text("Evaluate Delay: ${currentCubitState.evaluateDelay}s"),
              if (currentCubitState is NFATesterEvaluating)
                _InputEvaluatorIndicator(
                  currentCubitState: currentCubitState,
                ),
              TextButton(
                onPressed: () {
                  if (currentCubitState is NFATesterEvaluating) {
                    context.read<NFATesterCubit>().reset();
                  } else {
                    context.read<NFATesterCubit>().startEvaluation();
                  }
                },
                child: Text(
                  currentCubitState is NFATesterEvaluating ? "Reset" : "Start",
                ),
              ),
              if (currentCubitState is NFATesterEvaluating)
                Text(
                    "Current States: ${currentCubitState.currentStates.join(", ")}"),
              if (currentCubitState is NFATesterEvaluating &&
                  currentCubitState.isFinished)
                Text(
                  "Result: ${currentCubitState.isAccepted ? "Accepted" : "Rejected"}",
                ),
              _nfaVisualizer(currentStates)
            ],
          );
        },
      ),
    );
  }

  Expanded _nfaVisualizer(Set<int>? currentStates) {
    return Expanded(
      child: CachedNetworkImage(
        imageUrl:
            'https://quickchart.io/graphviz?graph=${Uri.encodeComponent(nfa.toDOT(currentStates))}&format=png&engine=dot',
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _DelaySelector extends StatelessWidget {
  final NFATesterState currentCubitState;
  const _DelaySelector({
    required this.currentCubitState,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: currentCubitState.evaluateDelay,
      onChanged: currentCubitState is NFATesterSettingUp
          ? (double value) {
              context.read<NFATesterCubit>().setEvaluateDelay(value);
            }
          : null,
      divisions: 8,
      min: 2,
      max: 10,
    );
  }
}

class _InputEvaluatorIndicator extends StatelessWidget {
  final NFATesterEvaluating currentCubitState;
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

showNFAInfoDialog(BuildContext context, NFA nfa, {String? description}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("NFA Info"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("States: ${nfa.states.join(", ")}"),
              Text("Alphabet: ${nfa.alphabet.join(", ")}"),
              const Text("Transitions:"),
              for (var entry in nfa.transitions.entries)
                Text(
                    "${entry.key} -> ${entry.value.entries.map((e) => "${e.key}: ${e.value.join(", ")}").join(", ")}"),
              Text("Initial State: ${nfa.initialState}"),
              Text("Final States: ${nfa.finalStates.join(", ")}"),
              if (description != null) Text("Description: $description"),
            ],
          ),
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
    },
  );
}
