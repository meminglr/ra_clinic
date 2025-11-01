import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ra_clinic/func/turkish_phone_formatter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';

class EditCostumerPage extends StatefulWidget {
  final CostumerModel costumer;
  final List<SeansModel> seansList;
  const EditCostumerPage({
    super.key,
    required this.costumer,
    required this.seansList,
  });

  @override
  State<EditCostumerPage> createState() => _EditCostumerPageState();
}

class _EditCostumerPageState extends State<EditCostumerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telNoController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<SeansModel> _seansList = [];
  final Map<SeansModel, TextEditingController> _controllers = {};

  DateTime now = DateTime.now();

  final _formKey = GlobalKey<FormState>();
  String kayitTarihi = "";
  String seansTarihi = "";

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.costumer.name;
    _telNoController.text = widget.costumer.phone ?? "";
    _noteController.text = widget.costumer.notes ?? "";
    _seansList = widget.seansList;
    for (var seans in widget.costumer.seansList!) {
      _controllers[seans] = TextEditingController(text: seans.seansNote);
    }

    musteriTarihVeSaatAl();
  }

  void removeSeans(int index) {
    if (_seansList.isNotEmpty) {
      _seansList[index].isDeleted = !_seansList[index].isDeleted;
      setState(() {});
    }
  }

  void seansEkle() {
    seansTarihSaatAl();
    _seansList.add(
      SeansModel(
        id: _seansList.length,
        startDate: now,
        startDateString: seansTarihi,
        seansCount: _seansList.length + 1,
      ),
    );
    setState(() {});
  }

  void musteriTarihVeSaatAl() {
    kayitTarihi = DateFormat('d MMMM y HH:mm', 'tr_TR').format(now);
    setState(() {});
  }

  void seansTarihSaatAl() {
    seansTarihi = DateFormat('d MMMM y', 'tr_TR').format(now);
    setState(() {});
  }

  void saveAndReturn() {
    if (_nameController.text.isNotEmpty || _formKey.currentState!.validate()) {
      final CostumerModel modifiedCostumer = CostumerModel(
        name: _nameController.text,
        phone: _telNoController.text,
        startDate: now,
        notes: _noteController.text,
        seansList: _seansList,
        startDateString: kayitTarihi,
      );
      Navigator.pop(context, modifiedCostumer);
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

      helpText: "Kayıt Tarihi",
      cancelText: "Vazgeç",
      confirmText: "Kaydet",
    );

    if (secilenTarih != null && secilenTarih != now) {
      setState(() {
        now = secilenTarih; // State'i güncelle
        musteriTarihVeSaatAl();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _telNoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Müşteri Düzenle")),
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
                    GestureDetector(
                      onTap: () {
                        _tarihSec(context);
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
                                          removeSeans(index);
                                        },
                                        label: Text("Sil"),
                                        icon: Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller: _controllers[seans],
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
