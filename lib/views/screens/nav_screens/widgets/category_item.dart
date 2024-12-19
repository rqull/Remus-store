import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mob3_uas_klp_04/controllers/category_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem extends StatefulWidget {
  const CategoryItem({super.key});

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  final CategoryController _categoryController = Get.find<CategoryController>();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _categoryController.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
                crossAxisCount: 4,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      Image.network(
                        _categoryController.categories[index].categoryImage,
                        width: 47,
                        height: 47,
                        fit: BoxFit.cover,
                      ),
                      Text(_categoryController.categories[index].categoryName,
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                fontSize: 14,
                                letterSpacing: 0.3,
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
