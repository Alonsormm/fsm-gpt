import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/pages/dfa_tester/dfa_tester_cubit.dart';

class DFATesterScreen extends StatelessWidget {
  final DFA dfa;
  final String? description;
  const DFATesterScreen({super.key, required this.dfa, this.description});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DFATesterCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Prueba de AFD"),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => DFAInfoDialog(
                    dfa: dfa,
                    description: description,
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        body: _DFATesterDisplay(dfa: dfa),
      ),
    );
  }
}

class _DFATesterDisplay extends StatelessWidget {
  final DFA dfa;
  const _DFATesterDisplay({required this.dfa});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<DFATesterCubit, DFATesterState>(
        builder: (context, currentCubitState) {
          int? currentState;
          if (currentCubitState is DFATesterEvaluating) {
            currentState = currentCubitState.currentState;
          } else if (currentCubitState is DFATesterFinished) {
            currentState = currentCubitState.currentState;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Input"),
                onChanged: (input) {
                  context.read<DFATesterCubit>().setInput(input);
                },
              ),
              _DelaySelector(
                currentCubitState: currentCubitState,
              ),
              if (currentCubitState is DFATesterEvaluating)
                _InputEvaluatorIndicator(
                  currentCubitState: currentCubitState,
                ),
              Text(
                  "Retardo en simulación: ${currentCubitState.evaluateDelay}s"),
              TextButton(
                onPressed: () {
                  startEvaluation(context);
                },
                child: const Text("Start"),
              ),
              if (currentCubitState is DFATesterEvaluating)
                Text("Estado Actual: q${currentCubitState.currentState}"),
              if (currentCubitState is DFATesterFinished)
                Column(
                  children: [
                    Text("Estado Actual: q${currentCubitState.currentState}"),
                    Text(
                      "Estados Finales: ${dfa.finalStates.map((e) => "q$e").join(", ")}",
                    ),
                    Text(
                      "Resultado: ${currentCubitState.isAccepted ? "Accepted" : "Rejected"}",
                    ),
                  ],
                ),
              _dfaVisualizer(currentState)
            ],
          );
        },
      ),
    );
  }

  Expanded _dfaVisualizer(int? currentState) {
    return Expanded(
      child: CachedNetworkImage(
        imageUrl:
            'https://quickchart.io/graphviz?graph=${Uri.encodeComponent(dfa.toDOT(currentState))}&format=png&engine=dot',
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void startEvaluation(BuildContext context) {
    context.read<DFATesterCubit>().startEvaluation(
          initialState: dfa.initialState,
          onTimerTick: () {
            final evaluatingState = context.read<DFATesterCubit>().state;
            if (evaluatingState is! DFATesterEvaluating) {
              return;
            }

            _evaluateState(context, evaluatingState);
          },
        );
  }

  void _evaluateState(
      BuildContext context, DFATesterEvaluating evaluatingState) {
    final nextState = dfa.nextState(
      evaluatingState.currentState,
      evaluatingState.input[evaluatingState.currentInputIndex],
    );

    if (nextState == null ||
        evaluatingState.currentInputIndex == evaluatingState.input.length - 1) {
      _finalizeEvaluation(context, evaluatingState, nextState == null);
      return;
    }

    context.read<DFATesterCubit>().updateEvaluation(
          currentState: nextState,
          currentInputIndex: evaluatingState.currentInputIndex + 1,
        );
  }

  void _finalizeEvaluation(
      BuildContext context, DFATesterEvaluating evaluatingState, bool failed) {
    final isFinalState =
        failed ? false : dfa.finalStates.contains(evaluatingState.currentState);
    evaluatingState.timer.cancel();
    context.read<DFATesterCubit>().stopEvaluation(isFinalState);
  }
}

class _DelaySelector extends StatelessWidget {
  final DFATesterState currentCubitState;
  const _DelaySelector({
    required this.currentCubitState,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: currentCubitState.evaluateDelay,
      onChanged: (value) {
        // value sometimes has a lot of decimals, so we round it to 1 decimal
        context.read<DFATesterCubit>().setEvaluateDelay(value);
      },
      divisions: 50,
      min: 1,
      max: 10,
    );
  }
}

class _InputEvaluatorIndicator extends StatelessWidget {
  final DFATesterEvaluating currentCubitState;
  const _InputEvaluatorIndicator({
    required this.currentCubitState,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
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

class DFAInfoDialog extends StatelessWidget {
  final DFA dfa;
  final String? description;
  const DFAInfoDialog({super.key, required this.dfa, this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("DFA Info"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Description: ${description ?? "No description"}"),
          Text("Estados: ${dfa.states.map((e) => "q$e").join(", ")}"),
          Text("Alfabeto: ${dfa.alphabet.join(", ")}"),
          Text("Estado Inicial: q${dfa.initialState}"),
          Text(
            "Estados Finales: ${dfa.finalStates.map((e) => "q$e").join(", ")}",
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
