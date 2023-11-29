import 'package:flutter/material.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/pages/dfa_tester/dfa_tester_screen.dart';

class DFACreator extends StatefulWidget {
  const DFACreator({super.key});

  @override
  State<DFACreator> createState() => _DFACreatorState();
}

class _DFACreatorState extends State<DFACreator> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  List<int> states = [];
  List<String> alphabet = [];
  Map<int, Map<String, int?>> transitions = {};
  int? initialState;
  Set<int> finalStates = {};
  TextEditingController stateController = TextEditingController();
  TextEditingController symbolController = TextEditingController();

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
      transitions[state] = {};
      stateController.clear();
    }
    setState(() {});
  }

  // Función para agregar un nuevo símbolo al alfabeto
  void addSymbol() {
    String symbol = symbolController.text.trim();
    if (symbol.isNotEmpty && !alphabet.contains(symbol)) {
      alphabet.add(symbol);
      symbolController.clear();
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
        ...alphabet.map((symbol) => ListTile(title: Text(symbol))).toList(),
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

  // Widget para el paso de definir transiciones
  Widget _transitionsStep() {
    List<Widget> widgets = [];

    for (int state in states) {
      for (String symbol in alphabet) {
        int? selectedState = transitions[state]?[symbol];
        if (selectedState == null || !states.contains(selectedState)) {
          // Asegurar que el valor seleccionado es válido o nulo
          selectedState = null;
          transitions[state]?[symbol] = null;
        }

        widgets.add(Row(
          children: <Widget>[
            Text('From q$state on $symbol go to '),
            DropdownButton<int>(
              value: selectedState,
              items: states.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('q$value'),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  transitions[state]?[symbol] = newValue;
                });
              },
            ),
          ],
        ));
      }
    }

    return Column(children: widgets);
  }

// Widget para el paso de definir estados iniciales y finales
  Widget _initialAndFinalStatesStep() {
    // Asegurar que el estado inicial esté en la lista de estados o sea nulo
    if (!states.contains(initialState)) {
      initialState = null;
    }

    // Eliminar de finalStates aquellos que ya no están en la lista de estados
    finalStates.removeWhere((state) => !states.contains(state));

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
        const Text('Final States'),
        ...states
            .map((state) => CheckboxListTile(
                  title: Text('q$state'),
                  value: finalStates.contains(state),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        finalStates.add(state);
                      } else {
                        finalStates.remove(state);
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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              if (states.isEmpty ||
                  alphabet.isEmpty ||
                  initialState == null ||
                  finalStates.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all the fields'),
                  ),
                );
                return;
              }
              final dfa = DFA(
                states: Set<int>.from(states),
                alphabet: Set<String>.from(alphabet),
                transitions: transitions.map((key, value) {
                  return MapEntry(key, Map<String, int>.from(value));
                }),
                initialState: initialState ?? 0,
                finalStates: finalStates,
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DFATesterScreen(dfa: dfa),
                ),
              );
            }
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
              subtitle: Text('Alphabet: ${alphabet.join(', ')}'),
            ),
            Step(
              title: const Text('Transitions'),
              content: _transitionsStep(),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
            ),
            Step(
              title: const Text('Initial and Final States'),
              content: _initialAndFinalStatesStep(),
              isActive: _currentStep >= 3,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }
}
