import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_04/views/screens/nav_screens/widgets/banner_widget.dart';
import 'package:mob3_uas_klp_04/views/screens/nav_screens/widgets/category_item.dart';
import 'package:mob3_uas_klp_04/views/screens/nav_screens/widgets/home_header_widget.dart';
import 'package:mob3_uas_klp_04/views/screens/nav_screens/widgets/recommended_product_widget.dart';
import 'package:mob3_uas_klp_04/views/screens/nav_screens/widgets/reuseable_text_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HomeHeaderWidget(),
            const BannerWidget(),
            const CategoryItem(),
            const ReuseableTextWidget(
                title: 'Recommended for you', subTitle: 'View all'),
            RecommendedProductWidget(),
          ],
        ),
      ),
    );
  }
}
