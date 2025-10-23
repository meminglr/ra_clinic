import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:ra_clinic/func/turkish_phone_formatter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';

class AddCostumerPage2 extends StatefulWidget {
  const AddCostumerPage2({super.key});

  @override
  State<AddCostumerPage2> createState() => _AddCostumerPage2State();
}

class _AddCostumerPage2State extends State<AddCostumerPage2> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telNoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<SeansModel> _seansList = [];

  DateTime now = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  String kayitTarihi = "";

  void removeSeans(int index) {
    if (_seansList.isNotEmpty) {
      _seansList[index].isDeleted = !_seansList[index].isDeleted;
      setState(() {});
    }
  }

  void seansEkle() {
    _seansList.add(
      SeansModel(
        "description",
        id: 1,
        name: "name",
        startDate: now,
        seansCount: _seansList.length + 1,
      ),
    );
    setState(() {});
  }

  void tarihVeSaatAl() {
    kayitTarihi =
        "${now.day}/${now.month}/${now.year} - ${now.hour}:${now.minute}";
    setState(() {});
  }

  void saveAndReturn() {
    if (_nameController.text.isNotEmpty || _formKey.currentState!.validate()) {
      final CostumerModel newCostumer = CostumerModel(
        id: "1",
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

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilenTarih = await showDatePicker(
      context: context,
      initialDate: now, // İlk gösterilecek tarih
      firstDate: DateTime(2000), // Seçilebilecek en erken tarih
      lastDate: DateTime(2030), // Seçilebilecek en geç tarih
    );

    if (secilenTarih != null && secilenTarih != now) {
      setState(() {
        now = secilenTarih; // State'i güncelle
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tarihVeSaatAl();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _telNoController.dispose();
    _noteController.dispose();
    for (var seans in _seansList) {
      seans.noteController.dispose();
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
                      decoration: InputDecoration(
                        hintText: "Müşteri ismini giriniz",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    TextFormField(
                      controller: _telNoController,
                      keyboardType: TextInputType.none,
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
                      decoration: InputDecoration(
                        hintText: "Not",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _tarihSec(context);
                        tarihVeSaatAl();
                      },
                      child: Text("Kayıt Tarihi: $kayitTarihi"),
                    ),
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
                              removeSeans(index);
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
                                      Text(
                                        "${seans.seansCount}. Seans",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      FilledButton.icon(
                                        onPressed: () {
                                          removeSeans(index);
                                        },
                                        label: Text("Sil"),
                                        icon: Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: seans.noteController,
                                    minLines: 1,
                                    maxLines: null,
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
