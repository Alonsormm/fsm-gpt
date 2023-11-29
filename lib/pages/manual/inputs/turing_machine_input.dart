// using this example widget for NFA input, we can create a similar widget for PDA input

import 'package:flutter/material.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
import 'package:fsm_gpt/pages/manual/turing_machine_tester.dart/turing_machine_tester_screen.dart';

class TuringMachineCreator extends StatefulWidget {
  const TuringMachineCreator({Key? key}) : super(key: key);

  @override
  State<TuringMachineCreator> createState() => _TuringMachineCreatorState();
}

class _TuringMachineCreatorState extends State<TuringMachineCreator> {
  int _currentStep = 0;
  List<int> states = [];
  List<String> inputAlphabet = ['_']; // Add ε to the alphabet
  List<String> tapeAlphabet = ['_'];
  List<TuringTransition> transitions = [];
  int? initialState;
  Set<int> acceptanceStates = {};
  TextEditingController stateController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  TextEditingController tapeSymbolController = TextEditingController();

  // Función para agregar un nuevo estado
  void addState() {
    int state = int.tryParse(stateController.text.trim()) ?? -1;
    if (state == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid state'),
        ),
      );
      return;
    }
    if (!states.contains(state)) {
      states.add(state);
      stateController.clear();
    }
    setState(() {});
  }

  void addTransition(TuringState currentState, String currentSymbol,
      TuringState nextState, String newSymbol, String direction) {
    final transition = TuringTransition(
      currentState: currentState,
      currentSymbol: currentSymbol,
      nextState: nextState,
      newSymbol: newSymbol,
      direction: direction,
    );
    transitions.add(transition);
    setState(() {});
  }

  // UI Steps (similar structure to DFACreator, with modifications for PDA-specific elements)
  // Función para agregar un nuevo símbolo al alfabeto
  void addSymbol() {
    String symbol = symbolController.text.trim();
    if (symbol.isNotEmpty && !inputAlphabet.contains(symbol)) {
      inputAlphabet.add(symbol);
      symbolController.clear();
    }
    setState(() {});
  }

  // Función para agregar un nuevo símbolo al alfabeto de la tape
  void addTapeSymbol() {
    String symbol = tapeSymbolController.text.trim();
    // add the symbol to the tape alphabet
    if (symbol.isNotEmpty && !tapeAlphabet.contains(symbol)) {
      tapeAlphabet.add(symbol);
      tapeSymbolController.clear();
    }
    setState(() {});
  }

  // Widget para el paso de definir estados
  Widget _statesStep() {
    return Column(
      children: <Widget>[
        ...states.map((state) => ListTile(title: Text('q$state'))).toList(),
        Row(
          children: [
            const Text('q '),
            Expanded(
              child: TextFormField(
                controller: stateController,
                decoration: const InputDecoration(labelText: 'State Name'),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: addState,
          child: const Text('Add State'),
        ),
      ],
    );
  }

  // Widget para el paso de definir alfabeto
  Widget _alphabetStep() {
    return Column(
      children: <Widget>[
        ...inputAlphabet
            .map((symbol) => ListTile(title: Text(symbol)))
            .toList(),
        TextFormField(
          controller: symbolController,
          decoration: const InputDecoration(labelText: 'Symbol'),
        ),
        ElevatedButton(
          onPressed: addSymbol,
          child: const Text('Add Symbol'),
        ),
      ],
    );
  }

  // Widget para el paso de definir alfabeto de la pila
  Widget _tapeAlphabetStep() {
    return Column(
      children: <Widget>[
        ...tapeAlphabet.map((symbol) => ListTile(title: Text(symbol))).toList(),
        TextFormField(
          controller: tapeSymbolController,
          decoration: const InputDecoration(labelText: 'Tape Symbol'),
        ),
        ElevatedButton(
          onPressed: addTapeSymbol,
          child: const Text('Add Tape Symbol'),
        ),
      ],
    );
  }

  Widget _transitionsStep() {
    List<Widget> widgets = [];

    // para cada transición, crear un widget que muestre la transición
    for (final transition in transitions) {
      widgets.add(
        ListTile(
          title: Text(transition.toString()),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                transitions.remove(transition);
              });
            },
          ),
        ),
      );
    }

    // agregar un widget para agregar una nueva transición
    widgets.add(
      TransactionInput(
        inputAlphabet: inputAlphabet,
        tapeAlphabet: tapeAlphabet,
        states: states.map((state) => TuringState(state)).toList(),
        onAddTransition: (transition) {
          // check if transition already exists
          if (transitions.contains(transition)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transition already exists'),
              ),
            );
            return;
          } else {
            setState(() {
              transitions.add(transition);
            });
          }
        },
      ),
    );

    return Column(children: widgets);
  }

  // Widget para el paso de definir estados iniciales y finales
  Widget _initialAndFinalStatesStep() {
    // Asegurar que el estado inicial esté en la lista de estados o sea nulo
    if (!states.contains(initialState)) {
      initialState = null;
    }

    // Eliminar de finalStates aquellos que ya no están en la lista de estados
    acceptanceStates.removeWhere((state) => !states.contains(state));

    return Column(
      children: <Widget>[
        const Text('Initial State'),
        DropdownButton<int?>(
          value: initialState,
          hint: const Text('Select Initial State'),
          items: states.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('q$value'),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              initialState = newValue;
            });
          },
          isExpanded: true,
        ),
        const Text('Acceptance States'),
        ...states
            .map((state) => CheckboxListTile(
                  title: Text('q$state'),
                  value: acceptanceStates.contains(state),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        acceptanceStates.add(state);
                      } else {
                        acceptanceStates.remove(state);
                      }
                    });
                  },
                ))
            .toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: const BouncingScrollPhysics(),
      currentStep: _currentStep,
      onStepTapped: (step) {
        setState(() {
          _currentStep = step;
        });
      },
      onStepContinue: () {
        if (_currentStep < 4) {
          setState(() {
            _currentStep += 1;
          });
        } else {
          if (states.isEmpty ||
              inputAlphabet.isEmpty ||
              tapeAlphabet.isEmpty ||
              initialState == null ||
              acceptanceStates.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all the fields'),
              ),
            );
            return;
          }
          final tm = TuringMachine(
            states: states.map((state) => TuringState(state)).toSet(),
            inputAlphabet: Set<String>.from(inputAlphabet),
            tapeAlphabet: Set<String>.from(tapeAlphabet),
            transitions: transitions,
            initialState: TuringState(initialState!),
            acceptanceStates:
                acceptanceStates.map((state) => TuringState(state)).toSet(),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  TuringMachineTesterScreen(turingMachine: tm),
            ),
          );
        }

        // final tm = TuringMachine.fromJson(
        //     '{"s":[0,1,2],"a":["_","0","1"],"i":["_","0","1"],"d":{"0":{"0":[0,"0","R"],"1":[1,"1","R"],"_":[2,"_","R"]},"1":{"0":[1,"0","R"],"1":[0,"1","R"],"_":[1,"_","R"]}},"s_0":0,"s_a":[2]}');
        // print(tm.toJson());
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => TuringMachineTesterScreen(turingMachine: tm),
        //   ),
        // );
      },
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() {
            _currentStep -= 1;
          });
        }
      },
      steps: <Step>[
        Step(
          title: const Text('States'),
          content: _statesStep(),
          isActive: _currentStep >= 0,
          state: StepState.indexed,
          subtitle: Text('States: ${states.map((s) => 'q$s').join(', ')}'),
        ),
        Step(
          title: const Text('Alphabet'),
          content: _alphabetStep(),
          isActive: _currentStep >= 1,
          state: StepState.indexed,
          subtitle: Text('Alphabet: ${inputAlphabet.join(', ')}'),
        ),
        Step(
          title: const Text('Tape Alphabet'),
          content: _tapeAlphabetStep(),
          isActive: _currentStep >= 2,
          state: StepState.indexed,
          subtitle: Text('Tape Alphabet: ${tapeAlphabet.join(', ')}'),
        ),
        Step(
          title: const Text('Transitions'),
          content: _transitionsStep(),
          isActive: _currentStep >= 3,
          state: StepState.indexed,
        ),
        Step(
          title: const Text('Initial and Acceptance States'),
          content: _initialAndFinalStatesStep(),
          isActive: _currentStep >= 4,
          state: StepState.indexed,
        ),
      ],
    );
  }
}

class TransitionsForm extends StatefulWidget {
  final void Function(TuringTransition) onAddTransition;
  const TransitionsForm({super.key, required this.onAddTransition});

  @override
  State<TransitionsForm> createState() => _TransitionsFormState();
}

class _TransitionsFormState extends State<TransitionsForm> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class TransactionInput extends StatefulWidget {
  final List<String> inputAlphabet;
  final List<String> tapeAlphabet;
  final List<TuringState> states;
  final void Function(TuringTransition) onAddTransition;

  const TransactionInput({
    super.key,
    required this.inputAlphabet,
    required this.tapeAlphabet,
    required this.states,
    required this.onAddTransition,
  });

  @override
  State<TransactionInput> createState() => _TransactionInputState();
}

class _TransactionInputState extends State<TransactionInput> {
  int? currentState;
  String? inputSymbol;
  int? nextState;
  String? newInputSymbol;
  String? direction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: 'Estado Actual'),
          items: widget.states
              .map((state) =>
                  DropdownMenuItem(value: state.name, child: Text('$state')))
              .toList(),
          value: currentState,
          onChanged: (value) {
            setState(() {
              currentState = value;
            });
          },
        ),
        // hacer un dropdown para el símbolo de entrada
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Símbolo de Entrada'),
          items: widget.inputAlphabet
              .map((symbol) =>
                  DropdownMenuItem(value: symbol, child: Text(symbol)))
              .toList(),
          value: inputSymbol,
          onChanged: (value) {
            setState(() {
              inputSymbol = value;
            });
          },
        ),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: 'Estado Siguiente'),
          items: widget.states
              .map((state) =>
                  DropdownMenuItem(value: state.name, child: Text('$state')))
              .toList(),
          value: nextState,
          onChanged: (value) {
            setState(() {
              nextState = value;
            });
          },
        ),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Reemplazar Símbolo'),
          items: widget.tapeAlphabet
              .map((symbol) =>
                  DropdownMenuItem(value: symbol, child: Text(symbol)))
              .toList(),
          value: newInputSymbol,
          onChanged: (value) {
            setState(() {
              newInputSymbol = value;
            });
          },
        ),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Dirección'),
          items: ['L', 'R']
              .map((direction) =>
                  DropdownMenuItem(value: direction, child: Text(direction)))
              .toList(),
          value: direction,
          onChanged: (value) {
            setState(() {
              direction = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: () {
            final transition = TuringTransition(
              currentState: TuringState(currentState!),
              currentSymbol: inputSymbol!,
              nextState: TuringState(nextState!),
              newSymbol: newInputSymbol!,
              direction: direction!,
            );
            // Limpiar los campos
            setState(() {
              currentState = null;
              inputSymbol = null;
              newInputSymbol = null;
              nextState = null;
              direction = null;
            });

            widget.onAddTransition(transition);
          },
          child: const Text('Agregar Transición'),
        ),
      ]
          .expand((widget) => [
                widget,
                const SizedBox(
                  height: 24,
                )
              ])
          .toList(),
    );
  }
}
