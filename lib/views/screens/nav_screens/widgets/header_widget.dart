import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.20,
      child: Stack(
        children: [
          Image.asset(
            'assets/icons/searchBanner.jpeg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 48,
            top: 68,
            child: SizedBox(
              width: 250,
              height: 20,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Enter text",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  prefix: Image.asset(
                    'assets/icons/searc1.png',
                  ),
                  suffix: Image.asset(
                    "assets/icons/cam.png",
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  focusColor: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
