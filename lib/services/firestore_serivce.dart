import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/costumer_model.dart';

class FirestoreService {
  // 'customers' adında bir tablo (koleksiyon) oluşturuyoruz
  final CollectionReference _customersRef = FirebaseFirestore.instance
      .collection('customers');

  // 1. MÜŞTERİ EKLEME / GÜNCELLEME
  Future<void> saveCustomer(CostumerModel customer) async {
    // Eğer customerId boşsa yeni kayıt, doluysa güncelleme mantığı
    // Ancak burada set() kullanarak ID'yi kendimiz yönetiyoruz veya otomatik ID'ye bırakabiliriz.

    // Yöntem A: ID'yi modelden alıp o ID ile kaydetmek (Önerilen)
    await _customersRef.doc(customer.customerId).set(customer.toMap());
  }

  // 2. MÜŞTERİLERİ GETİRME (Stream olarak - Canlı Veri)
  Stream<List<CostumerModel>> getCustomers() {
    return _customersRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Gelen veriyi (Map) bizim modelimize çeviriyoruz
        return CostumerModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 3. MÜŞTERİ SİLME
  Future<void> deleteCustomer(String customerId) async {
    await _customersRef.doc(customerId).delete();
  }
}
