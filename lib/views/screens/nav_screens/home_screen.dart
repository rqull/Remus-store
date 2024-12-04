import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_04/views/screens/nav_screens/widgets/banner_widget.dart';
import 'package:mob3_uas_klp_04/views/screens/nav_screens/widgets/header_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWidget(),
            BannerWidget(),
          ],
        ),
      ),
    );
  }
}
