import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/cart_provider.dart';

class ChekoutScreen extends ConsumerStatefulWidget {
  const ChekoutScreen({super.key});

  @override
  ConsumerState<ChekoutScreen> createState() => _ChekoutScreenState();
}

class _ChekoutScreenState extends ConsumerState<ChekoutScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProviderData = ref.read(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chekout',
        ),
      ),
    );
  }
}
