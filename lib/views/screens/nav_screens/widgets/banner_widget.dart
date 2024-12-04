import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kelas BannerWidget adalah widget stateful yang menampilkan banner
class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

// State untuk BannerWidget
class _BannerWidgetState extends State<BannerWidget> {
  // Instance dari FirebaseFirestore untuk mengakses koleksi Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List untuk menyimpan URL gambar banner
  final List _bannerImage = [];

  // Fungsi untuk mengambil banner dari Firestore
  getBanners() {
    return _firestore.collection('banners').get().then(
      (QuerySnapshot querySnapshot) {
        // Iterasi melalui dokumen yang diambil
        querySnapshot.docs.forEach(
          (doc) {
            setState(() {
              // Menambahkan URL gambar ke dalam list _bannerImage
              _bannerImage.add(doc['image']);
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    // Memanggil getBanners untuk mengambil data banner saat inisialisasi
    getBanners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: MediaQuery.of(context).size.width,
      child: PageView.builder(
        itemCount: _bannerImage.length,
        itemBuilder: (context, index) {
          return Image.network(
            _bannerImage[index],
          );
        },
      ),
    );
  }
}
