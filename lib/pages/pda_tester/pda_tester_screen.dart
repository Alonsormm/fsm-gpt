import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/pages/pda_tester/pda_tester_cubit.dart';
import 'package:fsm_gpt/services/export_service.dart';
import 'package:fsm_gpt/widgets/export_name_dialog.dart'; // Asegúrate de que esta clase exista

class PDATesterScreen extends StatelessWidget {
  final PDA pda;
  final String? description;
  const PDATesterScreen({super.key, required this.pda, this.description});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PDATesterCubit(pda: pda),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Prueba de PDA"),
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
                    exportService.exportJson(pda.toJson(), name);
                    break;
                  case ExportType.dot:
                    exportService.exportAsDot(pda.toDOT(null), name);
                    break;
                  case ExportType.pdf:
                    exportService.exportAsPDF(pda.toDOT(null), name);
                    break;
                  case ExportType.image:
                    exportService.exportAsImage(pda.toDOT(null), name);
                    break;
                  default:
                    break;
                }
              },
            ),
          ],
        ),
        body: _PDATesterDisplay(pda: pda),
      ),
    );
  }
}

class _PDATesterDisplay extends StatelessWidget {
  final PDA pda;
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
                decoration: const InputDecoration(labelText: "Entrada"),
                onChanged: (input) {
                  context.read<PDATesterCubit>().setInput(input);
                },
              ),
              _DelaySelector(
                currentCubitState: currentCubitState,
              ),
              Text(
                  "Retraso en la simulación: ${currentCubitState.evaluateDelay}s"),
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
                  currentCubitState is PDATesterEvaluating
                      ? "Volver a empezar"
                      : "Empezar",
                ),
              ),
              if (currentCubitState is PDATesterEvaluating) ...[
                Text(
                  "Estado Actual: ${currentCubitState.currentStates.join(", ")}",
                ),
                Text(
                  "Pila actual: ${currentCubitState.stack}",
                ),
              ],
              if (currentCubitState is PDATesterEvaluating &&
                  currentCubitState.isFinished)
                Text(
                  "Resultado: ${currentCubitState.isAccepted ? "Aceptado" : "Rechazado"}",
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

  Expanded _pdaVisualizer(Set<PDAState>? currentState) {
    return Expanded(
      child: CachedNetworkImage(
        imageUrl:
            'https://quickchart.io/graphviz?graph=${Uri.encodeComponent(pda.toDOT(currentState))}&format=svg&engine=dot',
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
      height: 64,
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
  final PDA pda;
  final String? description;
  const PDAInfoDialog({super.key, required this.pda, this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("PDA Info"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Descripcción: ${description ?? "No description"}"),
          Text("Estados: ${pda.states.join(", ")}"),
          Text("Alfabeto: ${pda.inputAlphabet.join(", ")}"),
          Text("Alfabeto de la pila: ${pda.stackAlphabet.join(", ")}"),
          Text("Estados iniciales: ${pda.initialState}"),
          Text("Estados finales: ${pda.acceptanceStates.join(", ")}"),
          const Text("Transiciones:"),
          for (final transition in pda.transitions) Text(transition.toString()),
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
