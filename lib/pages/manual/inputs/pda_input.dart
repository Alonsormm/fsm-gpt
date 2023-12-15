// using this example widget for NFA input, we can create a similar widget for PDA input

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/pages/pda_tester/pda_tester_screen.dart';

class PDACreator extends StatefulWidget {
  const PDACreator({Key? key}) : super(key: key);

  @override
  State<PDACreator> createState() => _PDACreatorState();
}

class _PDACreatorState extends State<PDACreator> {
  int _currentStep = 0;
  List<int> states = [];
  List<String> inputAlphabet = ['ε']; // Add ε to the alphabet
  List<String> stackAlphabet = ['Z0', 'ε'];
  List<PDATransition> transitions = [];
  int? initialState;
  String? initialStackSymbol;
  Set<int> acceptanceStates = {};
  TextEditingController stateController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  TextEditingController nextStateController = TextEditingController();
  TextEditingController stackSymbolController = TextEditingController();
  TextEditingController newStackSymbolController = TextEditingController();

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
      stateController.clear();
    }
    setState(() {});
  }

  // New method to handle PDA transitions
  void addTransition(int state, String inputSymbol, String stackSymbol) {
    var nextStates = nextStateController.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((s) => s != null && states.contains(s))
        .toSet();

    if (nextStates.isNotEmpty) {
      transitions.add(PDATransition(
        currentState: PDAState(state),
        inputSymbol: inputSymbol,
        stackSymbol: stackSymbol,
        nextState: PDAState(nextStates.first!),
        newStackSymbol: newStackSymbolController.text,
      ));
      nextStateController.clear();
    }
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

  // Función para agregar un nuevo símbolo al alfabeto de la pila
  void addStackSymbol() {
    String symbol = stackSymbolController.text.trim();
    if (symbol.isNotEmpty && !stackAlphabet.contains(symbol)) {
      stackAlphabet.add(symbol);
      stackSymbolController.clear();
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
        ...inputAlphabet
            .map((symbol) => ListTile(title: Text(symbol)))
            .toList(),
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

  // Widget para el paso de definir alfabeto de la pila
  Widget _stackAlphabetStep() {
    return Column(
      children: <Widget>[
        ...stackAlphabet
            .map((symbol) => ListTile(title: Text(symbol)))
            .toList(),
        TextFormField(
          controller: stackSymbolController,
          decoration: const InputDecoration(labelText: 'Símbolo de Pila'),
        ),
        ElevatedButton(
          onPressed: addStackSymbol,
          child: const Text('Agregar símbolo de pila'),
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
          title: Text(
            '(${transition.currentState}, ${transition.inputSymbol}, ${transition.stackSymbol}) -> (${transition.nextState}, ${transition.newStackSymbol})',
          ),
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
        stackAlphabet: stackAlphabet,
        states: states.map((state) => PDAState(state)).toList(),
        onAddTransition: (transition) {
          // check if transition already exists
          if (transitions.contains(transition)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La transición ya existe'),
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
        const Text('Seleccionar estados finales'),
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
              stackAlphabet.isEmpty ||
              initialState == null ||
              acceptanceStates.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all the fields'),
              ),
            );
            return;
          }
          final pda = PDA(
            states: states.map((state) => PDAState(state)).toSet(),
            inputAlphabet: Set<String>.from(inputAlphabet),
            stackAlphabet: Set<String>.from(stackAlphabet),
            // transitions are a list of PdaTransition objects
            transitions: transitions,
            initialState: PDAState(initialState!),
            initialStackSymbol: initialStackSymbol ?? '',
            acceptanceStates:
                acceptanceStates.map((state) => PDAState(state)).toSet(),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PDATesterScreen(pda: pda),
            ),
          );
        }
        // final pda = PDA.fromJson(
        //     '{"s":[0,1,2],"a":["ε","a","b"],"g":["Z0","ε","A"],"d":{"0":{"a":{"Z0":[0,"A"],"A":[0,"AA"]},"b":{"A":[1,"ε"]}},"1":{"b":{"A":[1,"ε"]},"ε":{"Z0":[2,"ε"]}}},"s_0":0,"g_0":"","f_s":[2]}');
        // debugPrint(pda.toJson());
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => PDATesterScreen(pda: pda),
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
          subtitle: Text('Alfabeto: ${inputAlphabet.join(', ')}'),
        ),
        Step(
          title: const Text('Alfabeto de la Pila'),
          content: _stackAlphabetStep(),
          isActive: _currentStep >= 2,
          state: StepState.indexed,
          subtitle: Text('Alfabeto de la Pila: ${stackAlphabet.join(', ')}'),
        ),
        Step(
          title: const Text('Transiciones'),
          content: _transitionsStep(),
          isActive: _currentStep >= 3,
          state: StepState.indexed,
        ),
        Step(
          title: const Text('Estados Iniciales y Finales'),
          content: _initialAndFinalStatesStep(),
          isActive: _currentStep >= 4,
          state: StepState.indexed,
        ),
      ],
    );
  }
}

class TransitionsForm extends StatefulWidget {
  final void Function(PDATransition) onAddTransition;
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
  final List<String> stackAlphabet;
  final List<PDAState> states;
  final void Function(PDATransition) onAddTransition;

  const TransactionInput({
    super.key,
    required this.inputAlphabet,
    required this.stackAlphabet,
    required this.states,
    required this.onAddTransition,
  });

  @override
  State<TransactionInput> createState() => _TransactionInputState();
}

class _TransactionInputState extends State<TransactionInput> {
  int? currentState;
  String? inputSymbol;
  String? stackSymbol;
  int? nextState;
  List<String> newStackSymbols = [];

  final newStackSymbolsController = TextEditingController();

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
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Símbolo de Pila'),
          items: widget.stackAlphabet
              .map((symbol) =>
                  DropdownMenuItem(value: symbol, child: Text(symbol)))
              .toList(),
          value: stackSymbol,
          onChanged: (value) {
            setState(() {
              stackSymbol = value;
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

        const Text(
          'Símbolos de Pila Nuevos, si es vacío, se elimina el símbolo superior de la pila, Si el simbolo es el mismo que el actual, no se modifica la pila',
        ),
        // MultiSelectDropDown(
        //   options: widget.stackAlphabet
        //       .map((symbol) => ValueItem(label: symbol, value: symbol))
        //       .toList(),
        //   controller: newStackSymbolsController,
        //   selectionType: SelectionType.single,
        //   onOptionSelected: (List<ValueItem> selectedOptions) {
        //     // Actualizar los símbolos de pila nuevos seleccionados
        //     setState(() {
        //       newStackSymbols =
        //           selectedOptions.map((option) => option.value!).toList();
        //     });
        //   },
        // ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: newStackSymbolsController,
                decoration:
                    const InputDecoration(labelText: 'Símbolos de Pila Nuevos'),
                inputFormatters: [
                  // only allow already declared stack symbols
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      widget.stackAlphabet.join('|'),
                    ),
                  ),
                ],
              ),
            ),
            // add a button to easy add epsilon
            TextButton(
              onPressed: () {
                setState(() {
                  newStackSymbolsController.text += 'ε';
                });
              },
              child: const Text('ε'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  newStackSymbolsController.text += 'Z0';
                });
              },
              child: const Text('Z0'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            // Agregar la transición
            final transition = PDATransition(
              currentState: PDAState(currentState!),
              inputSymbol: inputSymbol!,
              stackSymbol: stackSymbol!,
              nextState: PDAState(nextState!),
              newStackSymbol: newStackSymbolsController.text,
            );
            widget.onAddTransition(transition);
            // Limpiar los campos
            setState(() {
              currentState = null;
              inputSymbol = null;
              stackSymbol = null;
              nextState = null;
              newStackSymbols = [];
              newStackSymbolsController.clear();
            });
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
