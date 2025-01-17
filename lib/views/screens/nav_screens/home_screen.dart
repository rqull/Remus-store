import 'package:flutter/material.dart';

import 'widgets/banner_widget.dart';
import 'widgets/category_item.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/recommended_product_widget.dart';
import 'widgets/reuseable_text_widget.dart';


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
