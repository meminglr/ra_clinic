import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:ra_clinic/model/costumer_model.dart'; // Dosya adın buysa kalsın, ama customer_model.dart olması daha iyi

class CustomerProvider extends ChangeNotifier {
  static const String _boxName = "customersBox";
  late Box<CustomerModel> _box;

  CustomerProvider() {
    _box = Hive.box<CustomerModel>(_boxName);
    // BÜYÜK SIR: Hive kutusunu dinliyoruz!
    // Kutuda herhangi bir değişiklik (SyncService'den veya başka yerden)
    // olduğu an arayüze "Güncellen" emri gönderiyoruz.
    _box.listenable().addListener(() {
      notifyListeners();
    });
  }

  // --- GETTER ---
  List<CustomerModel> get customersList {
    // costumers -> customers
    return _box.values.where((c) => !c.isDeleted).toList();
  }

  // --- MÜŞTERİ EKLEME ---
  Future<void> addCustomer(CustomerModel newCustomer) async {
    // addCostumer -> addCustomer
    String finalId = newCustomer.customerId.isEmpty
        ? const Uuid().v4()
        : newCustomer.customerId;

    final customerToSave = newCustomer.copyWith(
      customerId: finalId,
      lastUpdated: DateTime.now(),
      isSynced: false,
      isDeleted: false,
    );

    await _box.put(finalId, customerToSave);
    notifyListeners();
  }

  // --- MÜŞTERİ DÜZENLEME ---
  Future<void> editCustomer(CustomerModel updatedCustomer) async {
    final customerToSave = updatedCustomer.copyWith(
      lastUpdated: DateTime.now(),
      isSynced: false,
    );

    await _box.put(customerToSave.customerId, customerToSave);
    notifyListeners();
  }

  // --- MÜŞTERİ SİLME (SOFT DELETE) ---
  Future<void> deleteCustomer(String customerId) async {
    final existingCustomer = _box.get(customerId);

    if (existingCustomer != null) {
      final deletedCustomer = existingCustomer.copyWith(
        isDeleted: true,
        isSynced: false,
        lastUpdated: DateTime.now(),
      );

      await _box.put(customerId, deletedCustomer);
      notifyListeners();
    }
  }

  // --- SEANS DEĞİŞİKLİĞİ SONRASI ---
  Future<void> updateCustomerAfterSeansChange(
    CustomerModel modifiedCustomer,
  ) async {
    final finalCustomer = modifiedCustomer.copyWith(
      lastUpdated: DateTime.now(),
      isSynced: false,
    );

    await _box.put(finalCustomer.customerId, finalCustomer);
    notifyListeners();
  }
}
