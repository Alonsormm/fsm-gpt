import 'dart:convert';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:fsm_gpt/models/nfa.dart';
import 'package:fsm_gpt/models/pda.dart';
import 'package:fsm_gpt/models/turning_machine.dart';
import 'package:fsm_gpt/pages/automatico/automatico_page.dart';
import 'package:fsm_gpt/pages/dfa_tester/dfa_tester_screen.dart';
import 'package:fsm_gpt/pages/manual/manual_page.dart';
import 'package:fsm_gpt/pages/manual/turing_machine_tester.dart/turing_machine_tester_screen.dart';
import 'package:fsm_gpt/pages/nfa_tester/nfa_tester_screen.dart';
import 'package:fsm_gpt/pages/pda_tester/pda_tester_screen.dart';
import 'package:fsm_gpt/services/import_service.dart';
import 'package:kartal/kartal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});
  static const cardSize = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Maquinas de Estado Finito - GPT",
          style: context.general.textTheme.titleLarge,
        ),
        actions: [
          // import button
          IconButton(
            onPressed: () async {
              final result = await fp.FilePicker.platform.pickFiles(
                allowedExtensions: ['json'],
                type: fp.FileType.custom,
                allowMultiple: false,
              );

              if (result == null) return;

              final file = result.files.single;
              final json = utf8.decode(file.bytes!);
              final fsm = await ImportService().importJson(json);
              Widget? page;
              if (fsm is DFA) {
                page = DFATesterScreen(dfa: fsm);
              } else if (fsm is NFA) {
                page = NFATesterScreen(nfa: fsm);
              } else if (fsm is TuringMachine) {
                page = TuringMachineTesterScreen(turingMachine: fsm);
              } else if (fsm is PDA) {
                page = PDATesterScreen(pda: fsm);
              }

              if (!context.mounted) return;

              if (page != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => page!,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Tipo de máquina no soportado"),
                  ),
                );
              }
            },
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            onPressed: () {
              launchUrlString('http://www.example.com');
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Center(
        child: Wrap(
          children: [
            SizedBox(
                width: cardSize,
                height: cardSize,
                child: _MenuOption(
                  title: "Modo manual",
                  icon: Icons.edit,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManualPage(),
                      ),
                    );
                  },
                )),
            SizedBox(
              width: cardSize,
              height: cardSize,
              child: _MenuOption(
                title: "Modo automático",
                icon: Icons.play_arrow,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AutomaticoPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title),
              const SizedBox(
                height: 4,
              ),
              Icon(icon),
            ],
          ),
        ),
      ),
    );
  }
}
