enum FSMType {
  dfa("Autómata Finito Deterministico"),
  nfa("Autómata Finito No Deterministico"),
  pda("Autómata de Pila"),
  turing("Máquina de Turing");

  final String label;

  const FSMType(this.label);
}
