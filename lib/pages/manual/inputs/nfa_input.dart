import 'package:flutter/material.dart';
import 'package:fsm_gpt/models/nfa.dart';
import 'package:fsm_gpt/pages/nfa_tester/nfa_tester_screen.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart'; // Ensure this model is adapted for NFA

class NFACreator extends StatefulWidget {
  const NFACreator({super.key});

  @override
  State<NFACreator> createState() => _NFACreatorState();
}

class _NFACreatorState extends State<NFACreator> {
  int _currentStep = 0;
  List<int> states = [];
  List<String> alphabet = []; // Add ε to the alphabet
  Map<int, Map<String, Set<int?>>> transitions =
      {}; // Change to handle multiple next states
  int? initialState;
  Set<int> finalStates = {};
  TextEditingController stateController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  TextEditingController nextStateController = TextEditingController();

  // Función para agregar un nuevo estado
  void addState() {
    int state = int.tryParse(stateController.text.trim()) ?? -1;
    if (state == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese un estado válido'),
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

  // New method to handle NFA transitions
  void addTransition(int state, String symbol) {
    var nextStates = nextStateController.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((s) => s != null && states.contains(s))
        .toSet();

    if (nextStates.isNotEmpty) {
      transitions[state]?[symbol] = nextStates;
      nextStateController.clear();
    }
    setState(() {});
  }

  // UI Steps (similar structure to DFACreator, with modifications for NFA-specific elements)
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
                decoration:
                    const InputDecoration(labelText: 'Nombre del estado'),
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: addState,
          child: const Text('Agregar estado'),
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
          decoration: const InputDecoration(labelText: 'Símbolo'),
        ),
        ElevatedButton(
          onPressed: addSymbol,
          child: const Text('Agregar símbolo'),
        ),
      ],
    );
  }

  Widget _transitionsStep() {
    List<Widget> widgets = [];

    for (int state in states) {
      for (String symbol in ['ε', ...alphabet]) {
        var selectedStates = transitions[state]?[symbol] ?? <int>{};
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Desde q$state con $symbol ir a '),
                MultiSelectDropDown(
                  options: states
                      .map((state) =>
                          ValueItem(label: 'q$state', value: '$state'))
                      .toList(),
                  onOptionSelected: (List<ValueItem> selectedOptions) {
                    selectedStates = selectedOptions
                        .map((option) => int.tryParse(option.value!))
                        .where((option) =>
                            option != null && states.contains(option))
                        .toSet();
                    transitions[state]?[symbol] = selectedStates;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
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
        const Text('Estado Inicial'),
        DropdownButton<int?>(
          value: initialState,
          hint: const Text('Seleccione un estado inicial'),
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
        const Text('Estados Finales'),
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
    return Stepper(
      physics: const BouncingScrollPhysics(),
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
                content: Text('Por favor ingrese todos los datos'),
              ),
            );
            return;
          }
          final nfa = NFA(
            states: Set<int>.from(states),
            alphabet: Set<String>.from(alphabet),
            transitions: transitions.map((key, value) {
              return MapEntry(key, value.map((key, value) {
                return MapEntry(key, Set<int>.from(value));
              }));
            }),
            initialState: initialState ?? 0,
            finalStates: finalStates,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => NFATesterScreen(nfa: nfa),
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
          title: const Text('Estados'),
          content: _statesStep(),
          isActive: _currentStep >= 0,
          state: StepState.indexed,
          subtitle: Text('Estados: ${states.map((s) => 'q$s').join(', ')}'),
        ),
        Step(
          title: const Text('Alfabeto'),
          content: _alphabetStep(),
          isActive: _currentStep >= 1,
          state: StepState.indexed,
          subtitle: Text('Alfabeto: ${alphabet.join(', ')}'),
        ),
        Step(
          title: const Text('Transiciones'),
          content: _transitionsStep(),
          isActive: _currentStep >= 2,
          state: StepState.indexed,
        ),
        Step(
          title: const Text('Estados Iniciales y Finales'),
          content: _initialAndFinalStatesStep(),
          isActive: _currentStep >= 3,
          state: StepState.indexed,
        ),
      ],
    );
  }
}
