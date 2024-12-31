import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../inner_screens/order_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderScreen(),
              ),
            );
          },
          child: const Text('My Orders'),
        ),
      ),
    );
  }
}
