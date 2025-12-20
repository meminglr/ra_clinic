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

  // --- STATE ---
  final Set<String> _uploadingFiles = {}; // Currently uploading filenames

  // --- GETTER ---
  List<CustomerModel> get customersList {
    return _box.values.where((c) => !c.isDeleted && !c.isArchived).toList();
  }

  List<CustomerModel> get archivedCustomersList {
    return _box.values.where((c) => !c.isDeleted && c.isArchived).toList();
  }

  bool isFileUploading(String fileName) {
    return _uploadingFiles.contains(fileName);
  }

  void markFileAsUploading(String fileName) {
    _uploadingFiles.add(fileName);
    notifyListeners();
  }

  void markFileAsUploaded(String fileName) {
    _uploadingFiles.remove(fileName);
    notifyListeners();
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
      isArchived: false,
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

  // --- ÇOKLU MÜŞTERİ SİLME (SOFT DELETE) ---
  Future<void> deleteCustomers(List<String> customerIds) async {
    for (var customerId in customerIds) {
      final existingCustomer = _box.get(customerId);
      if (existingCustomer != null) {
        final deletedCustomer = existingCustomer.copyWith(
          isDeleted: true,
          isSynced: false,
          lastUpdated: DateTime.now(),
        );
        await _box.put(customerId, deletedCustomer);
      }
    }
    notifyListeners();
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

  // --- ARŞİVLEME İŞLEMLERİ ---
  Future<void> archiveCustomer(String customerId) async {
    final existingCustomer = _box.get(customerId);

    if (existingCustomer != null) {
      final archivedCustomer = existingCustomer.copyWith(
        isArchived: true,
        isSynced: false,
        lastUpdated: DateTime.now(),
      );

      await _box.put(customerId, archivedCustomer);
      notifyListeners();
    }
  }

  Future<void> archiveCustomers(List<String> customerIds) async {
    for (var customerId in customerIds) {
      final existingCustomer = _box.get(customerId);
      if (existingCustomer != null) {
        final archivedCustomer = existingCustomer.copyWith(
          isArchived: true,
          isSynced: false,
          lastUpdated: DateTime.now(),
        );
        await _box.put(customerId, archivedCustomer);
      }
    }
    notifyListeners();
  }

  Future<void> unarchiveCustomer(String customerId) async {
    final existingCustomer = _box.get(customerId);

    if (existingCustomer != null) {
      final unarchivedCustomer = existingCustomer.copyWith(
        isArchived: false,
        isSynced: false,
        lastUpdated: DateTime.now(),
      );

      await _box.put(customerId, unarchivedCustomer);
      notifyListeners();
    }
  }

  Future<void> unarchiveCustomers(List<String> customerIds) async {
    for (var customerId in customerIds) {
      final existingCustomer = _box.get(customerId);
      if (existingCustomer != null) {
        final unarchivedCustomer = existingCustomer.copyWith(
          isArchived: false,
          isSynced: false,
          lastUpdated: DateTime.now(),
        );
        await _box.put(customerId, unarchivedCustomer);
      }
    }
    notifyListeners();
  }

  Future<void> unarchiveAll() async {
    final archivedCustomers = _box.values
        .where((c) => !c.isDeleted && c.isArchived)
        .toList();

    for (var customer in archivedCustomers) {
      final unarchived = customer.copyWith(
        isArchived: false,
        isSynced: false,
        lastUpdated: DateTime.now(),
      );
      await _box.put(customer.customerId, unarchived);
    }
    notifyListeners();
  }

  Future<void> moveAllArchivedToTrash() async {
    final archivedCustomers = _box.values
        .where((c) => !c.isDeleted && c.isArchived)
        .toList();

    for (var customer in archivedCustomers) {
      final deleted = customer.copyWith(
        isDeleted: true,
        // isArchived: true, // İstersek arşivde kalsın ama silinsin, ya da arşivden çıksın.
        // Genelde Trash'e gidince arşiv flag'i önemsizdir ama liste mantığında !isDeleted && isArchived baktığımız için sorun olmaz.
        // Yine de temiz olsun diye silindiğinde de arşiv flagini tutabiliriz veya resetleyebiliriz.
        // TrashBinPage sadece isDeleted'a bakıyor.
        isSynced: false,
        lastUpdated: DateTime.now(),
      );
      await _box.put(customer.customerId, deleted);
    }
    notifyListeners();
  }

  // --- ÇÖP KUTUSU İŞLEMLERİ ---

  // Silinmiş müşterileri getir
  List<CustomerModel> get deletedCustomersList {
    return _box.values.where((c) => c.isDeleted).toList();
  }

  // Müşteriyi geri yükle
  Future<void> restoreCustomer(String customerId) async {
    final existingCustomer = _box.get(customerId);

    if (existingCustomer != null) {
      final restoredCustomer = existingCustomer.copyWith(
        isDeleted: false,
        isSynced: false,
        lastUpdated: DateTime.now(),
      );

      await _box.put(customerId, restoredCustomer);
      notifyListeners();
    }
  }

  // Müşteriyi kalıcı olarak sil
  Future<void> permanentlyDeleteCustomer(String customerId) async {
    if (_box.containsKey(customerId)) {
      await _box.delete(customerId);
      notifyListeners();
    }
  }

  // Çöp kutusunu boşalt
  Future<void> clearTrash() async {
    final deletedKeys = _box.values
        .where((c) => c.isDeleted)
        .map((c) => c.customerId)
        .toList();

    if (deletedKeys.isNotEmpty) {
      await _box.deleteAll(deletedKeys);
      notifyListeners();
    }
  }

  // Tümünü geri yükle
  Future<void> restoreAllTrash() async {
    final deletedCustomers = _box.values.where((c) => c.isDeleted).toList();

    for (var customer in deletedCustomers) {
      final restored = customer.copyWith(
        isDeleted: false,
        isSynced: false,
        lastUpdated: DateTime.now(),
      );
      await _box.put(customer.customerId, restored);
    }
    notifyListeners();
  }

  // --- ÇOKLU GERİ YÜKLEME ---
  Future<void> restoreCustomers(List<String> customerIds) async {
    for (var customerId in customerIds) {
      final existingCustomer = _box.get(customerId);
      if (existingCustomer != null) {
        final restoredCustomer = existingCustomer.copyWith(
          isDeleted: false,
          isSynced: false,
          lastUpdated: DateTime.now(),
        );
        await _box.put(customerId, restoredCustomer);
      }
    }
    notifyListeners();
  }

  // --- ÇOKLU KALICI SİLME ---
  Future<void> permanentlyDeleteCustomers(List<String> customerIds) async {
    if (customerIds.isNotEmpty) {
      await _box.deleteAll(customerIds);
      notifyListeners();
    }
  }
}
