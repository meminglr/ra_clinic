import 'package:flutter/foundation.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';

class CostumerProvider extends ChangeNotifier {
  final List<CostumerModel> _costumersList = [];
  List<CostumerModel> get costumersList => List.unmodifiable(_costumersList);

  void addCostumer(CostumerModel newCostumer) {
    _costumersList.add(newCostumer);
    notifyListeners();
  }

  void editCostumer(int index, CostumerModel modifiedCostumer) {
    if (index >= 0 && index < _costumersList.length) {
      _costumersList[index] = modifiedCostumer;
      notifyListeners();
    }
  }

  void removeSeans(int index, List seansList) {
    if (seansList.isNotEmpty) {
      seansList[index].isDeleted = !seansList[index].isDeleted;
    }
    notifyListeners();
  }

  void seansEkle(SeansModel newSeans, List seansList) {
    seansList.add(newSeans);
    notifyListeners();
  }

  void deleteCostumer(int index) {
    if (index >= 0 && index < _costumersList.length) {
      _costumersList.removeAt(index);
      notifyListeners();
    }
  }
}
