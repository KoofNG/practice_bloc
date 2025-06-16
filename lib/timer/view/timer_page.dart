import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_blocs/ticker.dart';

import '../bloc/timer_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: Tickers()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Timer')),
      body: Stack(
        children: [
          SinusoidalMultiWave(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: TimerText()),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({super.key});
  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text('$minutesStr:$secondsStr', style: Theme.of(context).textTheme.displayLarge);
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...switch (state) {
              TimerInitial() => [
                FloatingActionButton(
                  child: const Icon(Icons.play_arrow),
                  onPressed: () => context.read<TimerBloc>().add(TimerStarted(duration: state.duration)),
                ),
              ],
              TimerRunInProgress() => [
                FloatingActionButton(child: const Icon(Icons.pause), onPressed: () => context.read<TimerBloc>().add(const TimerPaused())),
                FloatingActionButton(child: const Icon(Icons.replay), onPressed: () => context.read<TimerBloc>().add(const TimerReset())),
              ],
              TimerRunPause() => [
                FloatingActionButton(child: const Icon(Icons.play_arrow), onPressed: () => context.read<TimerBloc>().add(const TimerResumed())),
                FloatingActionButton(child: const Icon(Icons.replay), onPressed: () => context.read<TimerBloc>().add(const TimerReset())),
              ],
              TimerRunComplete() => [FloatingActionButton(child: const Icon(Icons.replay), onPressed: () => context.read<TimerBloc>().add(const TimerReset()))],
            },
          ],
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  const Background({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: SweepGradient(colors: [Colors.blue.shade50, Colors.blue.shade500], endAngle: 40.0),

        // LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.blue.shade50, Colors.blue.shade500]),
      ),
    );
  }
}

class SinusoidalMultiWave extends StatefulWidget {
  const SinusoidalMultiWave({super.key});

  @override
  _SinusoidalMultiWaveState createState() => _SinusoidalMultiWaveState();
}

class _SinusoidalMultiWaveState extends State<SinusoidalMultiWave> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _elapsedTime = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      setState(() {
        _elapsedTime = elapsed.inMilliseconds / 1000.0; // seconds
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MultiWavePainter(time: _elapsedTime),
      size: MediaQuery.of(context).size,
    );
  }
}

class MultiWavePainter extends CustomPainter {
  final double time;

  MultiWavePainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final waves = [
      WaveConfig(amplitude: 40, wavelength: size.width / 1.5, speed: 1.0, phaseOffset: 0, color: Colors.blueAccent.withOpacity(0.4)),
      WaveConfig(amplitude: 30, wavelength: size.width / 1.2, speed: 1.4, phaseOffset: pi / 2, color: Colors.purpleAccent.withOpacity(0.4)),
      WaveConfig(amplitude: 20, wavelength: size.width, speed: 1.8, phaseOffset: pi, color: Colors.cyan.withOpacity(0.4)),
    ];

    for (final wave in waves) {
      _drawWave(canvas, size, wave, time);
    }
  }

  void _drawWave(Canvas canvas, Size size, WaveConfig wave, double time) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = wave.color;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = sin((x / wave.wavelength * 2 * pi) + (time * wave.speed) + wave.phaseOffset) * wave.amplitude + size.height / 2;

      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MultiWavePainter oldDelegate) {
    return true;
  }
}

class WaveConfig {
  final double amplitude;
  final double wavelength;
  final double speed;
  final double phaseOffset;
  final Color color;

  WaveConfig({required this.amplitude, required this.wavelength, required this.speed, required this.phaseOffset, required this.color});
}
