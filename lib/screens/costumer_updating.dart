// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:ra_clinic/func/turkish_phone_formatter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';
import 'package:ra_clinic/utils.dart';

import '../constants/app_constants.dart';

class CostumerUpdating extends StatefulWidget {
  final CostumerModel? costumer;
  const CostumerUpdating({super.key, this.costumer});

  @override
  State<CostumerUpdating> createState() => _CostumerUpdatingState();
}

class _CostumerUpdatingState extends State<CostumerUpdating> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telNoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<SeansModel> _seansList = [];
  final Map<SeansModel, TextEditingController> _seansControllers = {};

  DateTime costumerStartDate = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  String kayitTarihi = "";
  String seansTarihi = "";

  @override
  void initState() {
    super.initState();
    if (widget.costumer == null) {
      for (var seans in _seansList) {
        _seansControllers[seans] = TextEditingController(text: seans.seansNote);
      }
    }

    if (widget.costumer != null) {
      _nameController.text = widget.costumer!.name;
      _telNoController.text = widget.costumer!.phone ?? "";
      _noteController.text = widget.costumer!.notes ?? "";
      _seansList = widget.costumer!.seansList;
      costumerStartDate = widget.costumer!.startDate;
      kayitTarihi = widget.costumer!.startDateString;
      for (var seans in widget.costumer!.seansList) {
        _seansControllers[seans] = TextEditingController(text: seans.seansNote);
      }
    }
    kayitTarihiGuncelle();
  }

  void removeSeans(int index, List seansList) {
    context.read<CostumerProvider>().removeSeans(index, seansList);
    setState(() {});
  }

  void seansEkle() {
    final newSeans = SeansModel(
      id: _seansList.length,
      startDate: DateTime.now(),
      startDateString: Utils.toDate(DateTime.now()),
      seansCount: _seansList.length + 1,
    );
    _seansControllers[newSeans] = TextEditingController();
    context.read<CostumerProvider>().seansEkle(newSeans, _seansList);
    setState(() {});
  }

  void kayitTarihiGuncelle() {
    kayitTarihi = Utils.toDate(costumerStartDate);
    setState(() {});
  }

  void saveAndReturn() {
    if (_nameController.text.isNotEmpty || _formKey.currentState!.validate()) {
      final id = Uuid().v4();
      final CostumerModel newCostumer = CostumerModel(
        id: id,
        name: _nameController.text,
        phone: _telNoController.text,
        startDate: costumerStartDate,
        notes: _noteController.text,
        seansList: _seansList,
        startDateString: kayitTarihi,
      );
      Navigator.pop(context, newCostumer);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gerekli alanları doldurunuz")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _telNoController.dispose();
    _noteController.dispose();
    for (var controller in _seansControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Müşteri Ekle")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveAndReturn();
          //  Navigator.pop(context);
        },
        label: const Text("Kaydet"),
        icon: const Icon(Icons.save_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 15,
                  children: [
                    Icon(Icons.account_circle, size: 150, color: Colors.grey),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen müşteri ismini giriniz';
                        }
                        return null;
                      },
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: "Müşteri ismini giriniz",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    TextFormField(
                      controller: _telNoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        AdaptiveTurkishPhoneFormatter(),
                        // Ek güvenlik için: + veya diğer karakterlere izin vermek isterseniz buraya ekleyebilirsiniz.
                        // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: InputDecoration(
                        hintText: "Telefon No",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    TextFormField(
                      controller: _noteController,
                      minLines: 1,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Not",
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                    ),
                    CupertinoCalendarPickerButton(
                      minimumDateTime: DateTime(2020, 1, 1),
                      maximumDateTime: DateTime(2030, 12, 31),
                      initialDateTime: costumerStartDate,
                      barrierColor: Colors.transparent,
                      containerDecoration: PickerContainerDecoration(
                        backgroundColor: AppConstants.dropDownButtonsColor(
                          context,
                        ),
                        backgroundType: PickerBackgroundType.plainColor,
                      ),
                      mode: CupertinoCalendarMode.date,
                      timeLabel: 'Saat',
                      onDateTimeChanged: (date) {
                        costumerStartDate = date;
                        kayitTarihiGuncelle();
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _seansList.length,
              itemBuilder: (context, index) {
                SeansModel seans = _seansList[index];
                return Column(
                  children: [
                    seans.isDeleted
                        ? FilledButton.tonal(
                            onPressed: () {
                              removeSeans(index, _seansList);
                            },
                            child: Text("${seans.seansCount}. Seansı Ekle"),
                          )
                        : Card.filled(
                            child: Column(
                              spacing: 10,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onInverseSurface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,

                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${seans.seansCount}. Seans·",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              seans.startDateString,
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              removeSeans(index, _seansList),
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _seansControllers[seans],
                                  minLines: 1,
                                  maxLines: null,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onChanged: (value) {
                                    seans.seansNote = value;
                                  },
                                  decoration: InputDecoration(
                                    filled: false,
                                    hintText: "Seans Notu Ekle",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 100,
                  left: 100,
                  right: 100,
                ),
                child: FilledButton(
                  onPressed: () {
                    seansEkle();
                  },
                  child: Text("Seans Ekle"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
