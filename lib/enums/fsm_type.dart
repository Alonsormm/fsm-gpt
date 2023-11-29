enum FSMType {
  dfa("Deterministic Finite Automata"),
  nfa("Non-deterministic Finite Automata"),
  pda("Pushdown Automata"),
  turing("Turing Machine");

  final String label;

  const FSMType(this.label);
}
