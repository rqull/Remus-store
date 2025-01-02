import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget {
  final Function(String) onSearch;
  final TextEditingController searchController;

  const HeaderWidget({
    Key? key,
    required this.onSearch,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: GoogleFonts.nunitoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: GoogleFonts.nunitoSans(
                color: Colors.grey,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              focusColor: Colors.black,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Color(0xFF103DE5),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
