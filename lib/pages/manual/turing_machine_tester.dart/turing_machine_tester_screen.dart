import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
import 'package:fsm_gpt/pages/manual/turing_machine_tester.dart/turing_machine_tester_cubit.dart';
import 'package:fsm_gpt/services/export_service.dart';
import 'package:fsm_gpt/widgets/export_name_dialog.dart';

class TuringMachineTesterScreen extends StatelessWidget {
  final TuringMachine turingMachine;
  final String? description;
  const TuringMachineTesterScreen(
      {super.key, required this.turingMachine, this.description});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TuringMachineTesterCubit(turingMachine: turingMachine),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Prueba de Máquina de Turing"),
          actions: [
            IconButton(
              onPressed: () {
                debugPrint(turingMachine.toJson());
                showDialog(
                  context: context,
                  builder: (context) => TuringMachineSummaryDialog(
                    description: description,
                    turingMachine: turingMachine,
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
                    exportService.exportJson(turingMachine.toJson(), name);
                    break;
                  case ExportType.dot:
                    exportService.exportAsDot(
                        turingMachine.toDOT(null, null, null), name);
                    break;
                  case ExportType.pdf:
                    exportService.exportAsPDF(
                        turingMachine.toDOT(null, null, null), name);
                    break;
                  case ExportType.image:
                    exportService.exportAsImage(
                        turingMachine.toDOT(null, null, null), name);
                    break;
                  default:
                    break;
                }
              },
            ),
          ],
        ),
        body: _TuringMachineTesterDisplay(turingMachine: turingMachine),
      ),
    );
  }
}

class _TuringMachineTesterDisplay extends StatelessWidget {
  final TuringMachine turingMachine;
  const _TuringMachineTesterDisplay({required this.turingMachine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<TuringMachineTesterCubit, TuringMachineTesterState>(
        builder: (context, currentCubitState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Entrada"),
                onChanged: (input) {
                  context.read<TuringMachineTesterCubit>().setInput(input);
                },
              ),
              const SizedBox(height: 8),
              const Text("Retraso en la simulación: "),
              _DelaySelector(currentCubitState: currentCubitState),
              Text('Retraso: ${currentCubitState.timerDuration} seconds'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  if (currentCubitState is TuringMachineTesterEvaluating) {
                    context.read<TuringMachineTesterCubit>().reset();
                  } else {
                    context.read<TuringMachineTesterCubit>().startEvaluation();
                  }
                },
                child: Text(
                  currentCubitState is TuringMachineTesterEvaluating
                      ? "Volver a empezar"
                      : "Empezar",
                ),
              ),
              if (currentCubitState is TuringMachineTesterEvaluating) ...[
                Text(
                  "Estado Actual: ${currentCubitState.currentState}",
                ),
                Text(
                  "Cinta actual: ${currentCubitState.tape.join("")}",
                ),
                Text(
                  "Posicion del cabezal: ${currentCubitState.headPosition}",
                ),
              ],
              if (currentCubitState is TuringMachineTesterEvaluating &&
                  currentCubitState.isFinished)
                Text(
                  "Result: ${currentCubitState.isAccepted ? "Accepted" : "Rejected"}",
                ),
              if (currentCubitState is TuringMachineTesterEvaluating)
                _turingMachineVisualizer(currentCubitState),
            ],
          );
        },
      ),
    );
  }

  Widget _turingMachineVisualizer(
      TuringMachineTesterEvaluating currentCubitState) {
    // Esta función debería retornar un widget que visualice la máquina de Turing.
    // Puede ser una imagen o un widget personalizado, según tus necesidades.
    final currentTape = currentCubitState.tape;
    final headPosition = currentCubitState.headPosition;

    return Expanded(
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: currentTape.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final currentSymbol = currentTape[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (index == headPosition)
                  const Icon(Icons.keyboard_arrow_down_rounded),
                Container(
                  width: 64,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: index == headPosition ? Colors.blue : Colors.grey,
                  ),
                  child: Text(
                    currentSymbol,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: index == headPosition
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 48,
                    ),
                  ),
                ),
                if (index == headPosition)
                  const Icon(Icons.keyboard_arrow_up_rounded),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DelaySelector extends StatelessWidget {
  final TuringMachineTesterState currentCubitState;
  const _DelaySelector({
    required this.currentCubitState,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: currentCubitState.timerDuration,
      onChanged: currentCubitState is TuringMachineTesterSettingUp
          ? (double value) {
              context.read<TuringMachineTesterCubit>().setTimerDuration(value);
            }
          : null,
      divisions: 9,
      min: 1,
      max: 10,
    );
  }
}

class TuringMachineSummaryDialog extends StatelessWidget {
  final TuringMachine turingMachine;
  final String? description;
  const TuringMachineSummaryDialog(
      {super.key, required this.turingMachine, this.description});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Máquina de Turing"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (description != null) Text("Descripción: $description"),
            Text("Estados: ${turingMachine.states.join(", ")}"),
            Text(
                "Alfabeto de la cinta: ${turingMachine.tapeAlphabet.join(", ")}"),
            Text("Alfabeto: ${turingMachine.inputAlphabet.join(", ")}"),
            Text("Transiciones:\n ${turingMachine.transitions.join("\n")}"),
            Text("Estado inicial: ${turingMachine.initialState}"),
            Text("Estado final: ${turingMachine.acceptanceStates.join(", ")}"),
          ],
        ),
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
