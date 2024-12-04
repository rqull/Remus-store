import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kelas BannerController mengelola logika untuk mengambil URL banner dari Firestore
class BannerController extends GetxController {
  // Instance dari FirebaseFirestore untuk mengakses koleksi Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mendapatkan stream dari URL banner
  Stream<List<String>> getBannerUrls() {
    // Mengambil snapshot dari koleksi 'banners' dan memetakan dokumen ke dalam list URL gambar
    return _firestore.collection('banners').snapshots().map(
      (snapshot) {
        // Mengembalikan list URL gambar dari dokumen yang diambil
        return snapshot.docs.map((doc) => doc['image'] as String).toList();
      },
    );
  }
}
