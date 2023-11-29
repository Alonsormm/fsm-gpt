import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
import 'package:fsm_gpt/pages/manual/turing_machine_tester.dart/turing_machine_tester_cubit.dart';

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
          title: const Text("Turing Machine Tester"),
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
                decoration: const InputDecoration(labelText: "Input"),
                onChanged: (input) {
                  context.read<TuringMachineTesterCubit>().setInput(input);
                },
              ),
              const SizedBox(height: 8),
              const Text("Delay"),
              _DelaySelector(currentCubitState: currentCubitState),
              Text('Delay: ${currentCubitState.timerDuration} seconds'),
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
                      ? "Reset"
                      : "Start",
                ),
              ),
              if (currentCubitState is TuringMachineTesterEvaluating) ...[
                Text(
                  "Current State: ${currentCubitState.currentState}",
                ),
                Text(
                  "Current Tape: ${currentCubitState.tape.join("")}",
                ),
                Text(
                  "Head Position: ${currentCubitState.headPosition}",
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

  Expanded _turingMachineVisualizer(
      TuringMachineTesterEvaluating currentCubitState) {
    // Esta función debería retornar un widget que visualice la máquina de Turing.
    // Puede ser una imagen o un widget personalizado, según tus necesidades.
    final currentTape = currentCubitState.tape;
    final headPosition = currentCubitState.headPosition;

    return Expanded(
      child: ListView.builder(
        itemCount: currentTape.length,
        itemBuilder: (context, index) {
          final currentSymbol = currentTape[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (index == headPosition) const Icon(Icons.arrow_back_ios),
              Text(
                currentSymbol,
                style: TextStyle(
                  fontWeight: index == headPosition
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              if (index == headPosition) const Icon(Icons.arrow_forward_ios),
            ],
          );
        },
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
      divisions: 8,
      min: 2,
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
      title: const Text("Turing Machine Summary"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (description != null) Text("Description: $description"),
            Text("States: ${turingMachine.states.join(", ")}"),
            Text("Tape Alphabet: ${turingMachine.tapeAlphabet.join(", ")}"),
            Text("Input Alphabet: ${turingMachine.inputAlphabet.join(", ")}"),
            Text("Transitions:\n ${turingMachine.transitions.join("\n")}"),
            Text("Initial State: ${turingMachine.initialState}"),
            Text(
                "Acceptance States: ${turingMachine.acceptanceStates.join(", ")}"),
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
  }
}
