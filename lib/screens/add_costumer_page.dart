import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/func/turkish_phone_formatter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';
import 'package:ra_clinic/utils.dart';
import 'package:uuid/uuid.dart';

class AddCostumerPage extends StatefulWidget {
  const AddCostumerPage({super.key});

  @override
  State<AddCostumerPage> createState() => _AddCostumerPageState();
}

class _AddCostumerPageState extends State<AddCostumerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telNoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<SeansModel> _seansList = [];
  final Map<SeansModel, TextEditingController> _seansControllers = {};

  DateTime now = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  String kayitTarihi = "";
  String seansTarihi = "";

  @override
  void initState() {
    super.initState();
    for (var seans in _seansList) {
      _seansControllers[seans] = TextEditingController(text: seans.seansNote);
    }
    musteriTarihVeSaatAl();
  }

  void removeSeans(int index, List seansList) {
    context.read<CostumerProvider>().removeSeans(index, seansList);
    setState(() {});
  }

  void seansEkle() {
    seansTarihSaatAl();
    final newSeans = SeansModel(
      id: _seansList.length,
      startDate: now,
      startDateString: seansTarihi,
      seansCount: _seansList.length + 1,
    );
    _seansControllers[newSeans] = TextEditingController();
    context.read<CostumerProvider>().seansEkle(newSeans, _seansList);
  }

  void musteriTarihVeSaatAl() {
    kayitTarihi = Utils.toDate(now);
    setState(() {});
  }

  void seansTarihSaatAl() {
    seansTarihi = Utils.toDate(now);
    setState(() {});
  }

  void saveAndReturn() {
    if (_nameController.text.isNotEmpty || _formKey.currentState!.validate()) {
      final id = Uuid().v4();
      final CostumerModel newCostumer = CostumerModel(
        id: id,
        name: _nameController.text,
        phone: _telNoController.text,
        startDate: now,
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
                  spacing: 16,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("assets/avatar.png"),
                    ),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                    ),
                    CupertinoCalendarPickerButton(
                      minimumDateTime: DateTime(2020, 1, 1),
                      maximumDateTime: DateTime(2030, 12, 31),
                      initialDateTime: now,
                      barrierColor: Colors.transparent,
                      containerDecoration: PickerContainerDecoration(
                        backgroundType: PickerBackgroundType.plainColor,
                      ),
                      mode: CupertinoCalendarMode.date,
                      timeLabel: 'Saat',
                      onDateTimeChanged: (date) {
                        now = date;
                        musteriTarihVeSaatAl();
                      },
                    ),
                    /* GestureDetector(
                      onTap: () {
                        _tarihSec(context);
                      },
                      child: Text("Kayıt Tarihi: $kayitTarihi"),
                    ),*/
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Colors.green.shade100,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                                bottom: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                      FilledButton.icon(
                                        onPressed: () {
                                          removeSeans(index, _seansList);
                                        },
                                        label: Text("Sil"),
                                        icon: Icon(Icons.delete_outline),
                                      ),
                                    ],
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
                                      hintText: "Seans Notu Ekle",
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
