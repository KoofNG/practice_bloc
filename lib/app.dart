import 'package:flutter/material.dart';
import 'package:practice_blocs/timer/timer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timers',
      theme: ThemeData(colorScheme: const ColorScheme.light(primary: Color.fromRGBO(72, 74, 126, 1))),
      home: const TimerPage(),
    );
  }
}
