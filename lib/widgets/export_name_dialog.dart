import 'package:flutter/material.dart';

class ExportNameDialog extends StatelessWidget {
  ExportNameDialog({Key? key}) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Exportar"),
      content: TextField(
        decoration: const InputDecoration(labelText: "Nombre"),
        controller: _controller,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: const Text("Exportar"),
        ),
      ],
    );
  }
}
