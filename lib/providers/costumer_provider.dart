import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';

class CostumerProvider extends ChangeNotifier {
  static const String _boxName = "costumersBox";
  final Box<CostumerModel> _box = Hive.box(_boxName);

  final List<CostumerModel> _costumersList = [];
  List<CostumerModel> get costumersList => List.unmodifiable(_costumersList);

  CostumerProvider() {
    _loadFromHive();
  }

  void _loadFromHive() {
    _costumersList.clear();
    _costumersList.addAll(_box.values.toList());
  }

  void _saveToHive() {
    _box.clear().then((onValue) {
      _box.addAll(_costumersList);
    });
  }

  void addCostumer(CostumerModel newCostumer) {
    _costumersList.add(newCostumer);
    _saveToHive();
    notifyListeners();
  }

  void editCostumer(int index, CostumerModel modifiedCostumer) {
    if (index >= 0 && index < _costumersList.length) {
      _costumersList[index] = modifiedCostumer;
      _saveToHive();
      notifyListeners();
    }
  }

  void removeSeans(int index, List seansList) {
    if (seansList.isNotEmpty) {
      seansList[index].isDeleted = !seansList[index].isDeleted;
    }
    _saveToHive();
    notifyListeners();
  }

  void seansEkle(SeansModel newSeans, List seansList) {
    seansList.add(newSeans);
    _saveToHive();
    notifyListeners();
  }

  void deleteCostumer(int index) {
    if (index >= 0 && index < _costumersList.length) {
      _costumersList.removeAt(index);
      _saveToHive();
      notifyListeners();
    }
  }
}
