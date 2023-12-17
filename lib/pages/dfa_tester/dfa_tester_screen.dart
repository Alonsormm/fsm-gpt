import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_img/flutter_img.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/pages/dfa_tester/dfa_tester_cubit.dart';
import 'package:fsm_gpt/services/export_service.dart';
import 'package:fsm_gpt/widgets/export_name_dialog.dart';

class DFATesterScreen extends StatelessWidget {
  final DFA dfa;
  final String? description;
  const DFATesterScreen({super.key, required this.dfa, this.description});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DFATesterCubit(dfa: dfa),
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
            PopupMenuButton<ExportType>(
              itemBuilder: (context) {
                return ExportType.values.map((exportType) {
                  return PopupMenuItem<ExportType>(
                    value: exportType,
                    child: Text(exportType.label),
                  );
                }).toList();
              },
              onSelected: (value) async {
                final exportService = ExportService();
                final name = await showDialog<String>(
                  context: context,
                  builder: (context) => ExportNameDialog(),
                );

                if (name == null) return;

                switch (value) {
                  case ExportType.json:
                    exportService.exportJson(dfa.toJson(), name);
                    break;
                  case ExportType.dot:
                    exportService.exportAsDot(dfa.toDOT(null), name);
                    break;
                  case ExportType.pdf:
                    exportService.exportAsPDF(dfa.toDOT(null), name);
                    break;
                  case ExportType.image:
                    exportService.exportAsImage(dfa.toDOT(null), name);
                    break;
                  default:
                    break;
                }
              },
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
              if (currentCubitState is DFATesterEvaluating &&
                  currentCubitState.isFinished)
                Column(
                  children: [
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
            'https://quickchart.io/graphviz?graph=${Uri.encodeComponent(dfa.toDOT(currentState))}&format=svg&engine=dot',
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void startEvaluation(BuildContext context) {
    context.read<DFATesterCubit>().startEvaluation();
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
