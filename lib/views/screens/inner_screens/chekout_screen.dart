import 'package:flutter/material.dart';

class ChekoutScreen extends StatefulWidget {
  const ChekoutScreen({super.key});

  @override
  State<ChekoutScreen> createState() => _ChekoutScreenState();
}

class _ChekoutScreenState extends State<ChekoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chekout',
        ),
      ),
    );
  }
}
