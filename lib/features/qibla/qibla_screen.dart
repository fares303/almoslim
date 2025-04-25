import 'package:flutter/material.dart';
import 'package:al_moslim/features/qibla/widgets/qibla_compass.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('القبلة'), centerTitle: true),
      body: const QiblaCompass(),
    );
  }
}
