import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:fsm_gpt/home_widget.dart';
import 'package:fsm_gpt/models/dfa.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  OpenAI.apiKey = const String.fromEnvironment('OPENAI_API_KEY');
  OpenAI.requestsTimeOut = const Duration(minutes: 1);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final textController = TextEditingController();
  DFA? dfa;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const HomeWidget(),
      title: 'FSM GPT',
      theme: ThemeData(useMaterial3: false),
    );
  }
}
