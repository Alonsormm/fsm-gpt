import 'package:flutter/material.dart';
import 'package:fsm_gpt/pages/automatico/automatico_page.dart';
import 'package:fsm_gpt/pages/manual/manual_page.dart';
import 'package:kartal/kartal.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});
  static const cardSize = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FSM GPT",
          style: context.general.textTheme.titleLarge,
        ),
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
